# Auto-generated by Terraform. Touch at your peril.

[all:vars]                    # --- global Ansible defaults ---
ansible_user=ansible          # non-privileged account with sudoers --> ALL=(ALL) NOPASSWD: ALL
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_private_key_file=${ssh_priv_key_path}
host_key_checking=True
strip_ssh_key_lines=False

# Jump through the bastion so the private subnet stays private
ansible_ssh_common_args='-o ProxyCommand="ssh -i ${ssh_priv_key_path} -W %h:%p ansible@${bastion_ip}"'

[k3s_servers]
%{- for ip in k3s_servers_private ~}
${ip}
%{- endfor }

[k3s_workers]
%{- for ip in k3s_workers_private ~}
${ip}

[loadbalancer]
${lb_private_ip}
