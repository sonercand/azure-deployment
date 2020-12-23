az policy definition create --name LinuxPasswordPolicy --display-name "Audit existing Linux VMs that use password for SSH authentication" --description "This policy audits if a password is being used to authentication to a Linux VM" --rules audit_linux_vm_password.json --mode All

