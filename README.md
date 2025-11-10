# waitforssh

**waitforssh** is a lightweight utility, written in POSIX shell, that waits for a target to be up and running via SSH and, if so, executes a command.

## Installation

```sh
pkg install waitforssh
```

## Motivation

When I deploy VMs using tools such as [Overlord](https://github.com/DtxdF/overlord), I have to wait for the virtual machine to be up and running, which means I have to wait for sshd to be ready before I can access the virtual machine and do things here and there. In most cases, I use Ansible to automate the post-provisioning step, but first I have to wait for sshd, and due to the asynchronous nature of Overlord, it's not fun to have to check the current status over and over again. In other cases, I use a virtual machine with an operating system other than FreeBSD to perform other tasks. All of these virtual machines are ephemeral, in the sense that I can destroy them after all tasks are completed.

So **waitforssh** was born to wait for sshd to be up and running and also check if we can access the system. There are two very simple examples I can show here:

1. [Create an asset for the backrest port](https://github.com/DtxdF/port-assets-makejails/blob/main/backrest/wait-and-download.sh#L12), which means creating a virtual machine with Debian, building the asset, and downloading it from the virtual machine to my host.
2. Create the virtual machine used by the [Centralized Repository](https://github.com/AppJail-makejails) to build AppJail images using Buildbot:

   ```sh
   overlord apply -f pubVM/cicd.yml &&
   waitforssh control-cicd &&
   cd ~/Devel/internal/ansible-deployments &&
   ansible-playbook --skip-tags dnsmasq --vault-password-file ~/.ansible_password.txt -i inventory.yml -l cicd \
        playbooks/pkg.yml \
        playbooks/appjail.yml \
        playbooks/backrest.yml \
        playbooks/cicd.yml
   ```

   Yeah, I destroy the virtual machine every time I want to change something or simply update it, which simply involves changing a parameter in my deployment file. If you are interested in the details of how I implemented this, see [this document](https://github.com/DtxdF/overlord/wiki/ephemeral_vm).

## Documentation

* `man 1 waitforssh`

## Contributing

If you have found a bug, have an idea or need help, use the [issue tracker](https://github.com/DtxdF/waitforssh/issues/new). Of course, PRs are welcome.
