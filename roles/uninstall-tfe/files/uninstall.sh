#!/bin/bash

####################################################################
##                                                                ##
## This script will uninstall Terraform Enterprise and the        ##
## Replicated services. This script is meant to be run via:       ##
##                                                                ##
## 'curl https://install.terraform.io/tfe/uninstall | sudo bash' ##
##                                                                ##
####################################################################

set -e -u -o pipefail

## Set up some colors and things for readability
bold=$(tput bold)
red=$(tput setaf 1)
normal=$(tput sgr0)

## Determine what Operating System is running
checkOS() {
	osname=
	if [ -f /etc/centos-release ] && [ -r /etc/centos-release ]; then
		osname="$(cat /etc/centos-release | cut -d" " -f1)"
	elif [ -f /etc/os-release ] && [ -r /etc/os-release ]; then
		osname="$(. /etc/os-release && echo "$ID")"
	elif [ -f /etc/redhat-release ] && [ -r /etc/redhat-release ]; then
		osname="rhel"
	elif [ -f /etc/system-release ] && [ -r /etc/system-release ]; then
		if grep --quiet "Amazon Linux" /etc/system-release; then
			osname="amzlnx"
		fi
	else 
		errormsg="${red}${bold}The OS either cannot be determined, or is not a supported OS, exiting.${normal}"
	fi

	if [ -z "$osname" ]; then
		echo -e >&2 "$(echo | sed "i$errormsg")"
		echo >&2 ""
		echo >&2 "${bold}Please contact support@hashicorp.com for assistance.${normal}"
		exit 1
	fi
}

## Check if Replicated is installed
commandExists() {
	command -v "$@" > /dev/null 2>&1
}
replicatedInstalled() {
	commandExists /usr/local/bin/replicatedctl && /usr/local/bin/replicatedctl version >/dev/null 2>&1
}

## Check what init system is in use
checkInit() {
	initsys=
	if [ -f /run/systemd/system ] || [ -d /run/systemd/system ]; then
		initsys=systemd
	elif [[ "$(/sbin/init --version 2>/dev/null)" =~ upstart ]]; then
		initsys=upstart
	elif [ -f /etc/init.d/cron ] && [ ! -h /etc/init.d/cron ]; then
		initsys=sysvinit
	else 
		echo >&2 "${red}${bold}Error: Cannot detect init system.${normal}"
		exit 1
	fi
}

#############################
## Let's start the script...
#############################

checkOS
checkInit

# Are you super sure you wanna do this?
if replicatedInstalled; then
	echo "${bold}This script will completely uninstall Terraform Enterprise and Replicated on this system, as well as remove associated files.${normal}"
	read -n 1 -t 15 -p "${bold}Do you wish to continue? (y/n)${normal}" choice
	case ${choice:0:1} in 
		y|Y ) echo es;;
		* ) echo "${bold}...uninstall cancelled...${normal}"
		exit;;
	esac
	
	echo "${bold}Proceeding with uninstall...${normal}"
else 
	read -n 1 -t 15 -p "${bold}Replicated does not appear to be installed on this system, do you wish to proceed anyway? (y/n)${normal}" choice
	case ${choice:0:1} in 
		y|Y ) echo es
		echo "${bold}I will attempt to proceed, you may see errors depending on what's present on the system.${normal}"
			  ;;
		* ) echo "${bold}...uninstall cancelled...${normal}"
		exit;;
	esac
fi

# Check for snapshots and ask to move them elsewhere
SNAPDIR="/var/lib/replicated/snapshots"
if [ -d "$SNAPDIR/files" ]; then
	if [ "$(ls -A $SNAPDIR/files)" ]; then
		echo "${red}${bold}There appear to be Replicated snapshots stored in /var/lib/replicated/snapshots.${normal}"
		PS3='Select an option: '
		options=("Move the snapshots to another directory" "Continue uninstall and delete the snapshots" "Cancel the uninstall")
		select a in "${options[@]}"; do
			case $a in 
				"Move the snapshots to another directory")
					read -e -p "Enter the directory to move the snapshots to: " BACKUPPATH
					echo "The snapshots will be moved to $BACKUPPATH."
					read -n 1 -p "Press Y to continue or N to cancel. " confirm
					case ${confirm:0:1} in 
						y|Y ) echo " "
							  echo "Moving snapshots..."
							  /bin/mkdir -p $BACKUPPATH/snapshot-backup
							  /bin/mv /var/lib/replicated/snapshots/* $BACKUPPATH/snapshot-backup/ 
							  echo "Files moved."
							  break
							  ;;
						* ) echo " Cancelled..."
							exit;;
					esac
				;;
				"Continue uninstall and delete the snapshots")
					echo "Uninstall will proceed."
					break
				;;
				"Cancel the uninstall")
					echo "Cancelling"
					exit;;
			esac
		done
	fi
fi				


# Stop the replicated services if they are running
if [ "$initsys" = "systemd" ]; then
	echo "${bold}Stopping and disabling the replicated services...${normal}"
	systemctl stop replicated replicated-ui replicated-operator || echo "${red}${bold}Unable to stop the services, possibly because they were not running.${normal}"
	systemctl disable replicated replicated-ui replicated-operator || echo "${red}${bold}Unable to disable the services, possibly because they are not installed.${normal}"
	echo "${bold}Replicated services stopped and disabled.${normal}"
elif [ "$initsys" = "upstart" ] || [ "$initsys" = "sysvinit" ]; then
	echo "${bold}Stopping the Replicated services...${normal}"
	service replicated stop || echo "${red}${bold}Unable to stop replicated, possibly because it's not running.${normal}"
	service replicated-ui stop || echo "${red}${bold}Unable to stop replicated-ui, possibly because it's not running.${normal}"
	service replicated-operator stop || echo "${red}${bold}Unable to stop replicated-operator, possibly because it's not running.${normal}"
	echo "${bold}Replicated services stopped.${normal}"
fi
echo "${bold}Stopping any running application containers${normal}"
/usr/bin/docker container kill $(docker container ls -f name=tfe -q) || echo "${red}${normal}Unable to stop application containers, possibly because none are running.${normal}"
/usr/bin/docker kill rabbitmq telegraf influxdb anchor_isolation_network || echo "${red}${normal}Unable to stop application containers, possibly because none are running.${normal}"

# Now we'll remove the replicated containers
echo "${bold}Removing Replicated Docker containers...${normal}"
/usr/bin/docker rm -f replicated replicated-ui replicated-operator replicated-premkit replicated-statsd retraced-api retraced-processor retraced-cron retraced-nsqd retraced-postgres || echo "${red}${bold}Some or all of the replicated containers were not found, moving along...${normal}"

# Clean up files and executables
echo "${bold}Removing Replicated files and executables...${normal}"
rm -rf /etc/default/replicated* /etc/init.d/replicated* /etc/init/replicated* /etc/replicated.alias /etc/sysconfig/replicated* /etc/systemd/system/multi-user.target.wants/replicated* /etc/systemd/system/replicated* /run/replicated* /usr/local/bin/replicated* /var/lib/replicated* /var/log/upstart/replicated* || echo "${red}${bold}Some or all of the files were not removed, moving along...${normal}"

# If this using systemd, reload the daemon
if [ "$initsys" = "systemd" ]; then
	echo "${bold}Run systemctl daemon-reload...${normal}"
	systemctl daemon-reload || echo "${red}${bold}Daemon-reload failed, continuing... ${normal}"
fi

# Do we want to prune all the docker volumes, or just the app-specific ones?
echo "${bold}Terraform Enterprise and Replicated should now be uninstalled.${normal}"
echo ""
echo "${bold}I can now clean up the Docker images for you.${normal}"
PS3='Select an option: '
options=("Prune all Docker volumes" "Prune only application Docker volumes" "Skip this step")
select a in "${options[@]}"; do
	case $a in 
		"Prune all Docker volumes") 
			echo "${bold}Prunning all Docker volumes...${normal}"
			/usr/bin/docker system prune --all --volumes || echo "${red}${bold}Unable to prune all volumes.${normal}"
			echo "${bold}Done.${normal}"
			break
			;;
		"Prune only application Docker volumes")
			echo "${bold}Only pruning the application Docker volumes...${normal}"
			/usr/bin/docker rm -f $(docker images | grep -E "quay.io/replicated|registry.replicated.com|terraformenterprise|replicated/sleep|hashicorp/build-worker|^.+:9874\/" | awk '{print $3}') || echo "${red}${bold}Error pruning Docker volumes.${normal}"
			echo "${bold}Done.${normal}"
			break
			;;
		"Skip this step")
			echo "${bold}Skipping Docker prune${normal}"
			break
			;;
		*) echo "${red}${bold}invalid option $REPLY${normal}";;
	esac
done

# Remove the Replicated docker network
echo "${bold}Removing the Replicated and TFE Docker networks...${normal}"
/usr/bin/docker network rm replicated_retraced tfe_services tfe_terraform_isolation || echo "${red}${bold}Unable to remove all Docker application networks, or none to be removed.${normal}"
echo "${bold}Done.${normal}"

# Final clean up of any dangling docker volumes
echo "${bold}Removing any dangling Docker volumes...${normal}"
/usr/bin/docker volume rm $(docker volume ls -q --filter "dangling=true") || echo "${red}${bold}Unable to remove dangling Docker volumes, or none to be removed.${normal}"

echo ""
echo "${bold}Uninstall Complete"
echo ""
echo "If you ran into any unexpected errors, please contact support@hashicorp.com"
echo "or visit the following url:" 
echo "https://support.hashicorp.com/hc/en-us/articles/360043134793-Uninstalling-Terraform-Enterprise${normal}"

exit 0
