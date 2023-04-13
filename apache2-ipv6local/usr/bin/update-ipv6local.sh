#!/bin/bash

PREFIX_LENGTH=60
TARGET=/etc/apache2/conf-available/00-ipv6.conf

# Get the global IPv6 addresses
ipv6_addresses=$(host $(hostname) | grep -E 'IPv6 address' | awk '{print $NF}')

# Exclude known self-allocated addresses (starting with fde8) and link-local addresses (starting with fe80)
global_ipv6_address=""
for addr in $ipv6_addresses; do
  if [[ ! $addr =~ ^(fde8|fe80) ]]; then
    global_ipv6_address=$addr
    break
  fi
done

if [ -z "$global_ipv6_address" ]; then
  # Not really a prefix, but a safe default for "Require ip ${LocalIPv6}" Apache2 directives
  prefix="::1"
else
  # Convert the IPv6 address to canonical form, keep only 60 bits
  canonical_ipv6_address="$(ipv6calc --in ipv6 --out ifinet6 $global_ipv6_address | cut -c -$(($PREFIX_LENGTH / 4)))00000000000000000"
  prefix="$(ipv6calc --in ifinet6 --out ipv6addr --printcompressed $canonical_ipv6_address)/60"
fi

# Mettez à jour le fichier 00-ipv6.conf avec la nouvelle valeur de IPv6Local
# Create a temporary file
mkdir -p $(dirname $TARGET)
temp_conf_file=$(mktemp -p $(dirname $TARGET))

# Write the new configuration to the temporary file
echo "# The IPv6 address radix is given by the ISP using Prefix Delegation." > $temp_conf_file
echo "# It may change over time and should be available to Apache 2." >> $temp_conf_file

echo "Define IPv6Local ${prefix}" >> $temp_conf_file

echo "# Autogenerated by update_ipv6local.sh" >> $temp_conf_file

if ! cmp -s "$TARGET" "$temp_conf_file"; then
  # Replace the original file with the temporary file
  mv -f "$temp_conf_file" "$TARGET"
  
  # Log the change to syslog
  logger -t "update_ipv6local" "The IPv6 prefix has changed to ${prefix}"

  # Check if configuration is enabled
  if a2query -qc 00-ipv6; then
    # Restart Apache (must run as root) if it is running
    systemctl try-reload-or-restart apache2
  fi
else
  # Remove the temporary file
  rm "$temp_conf_file"
fi
