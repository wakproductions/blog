---
title: Docker installation on AWS/Ubuntu Xenial made Easy with Ansible
date: 2017-06-03
tags:
---

Here is the Ansible role based [on the official Docker installation guide](https://docs.docker.com/engine/installation/linux/ubuntu/#prerequisites)

```yml
---
# This is aimed towards Ubuntu Xenial 16

- name: Uninstall Old Versions
  apt:
    pkg:          "{{ item }}"
    state:        absent
  with_items:
    - docker
    - docker-engine

- name: Install dependencies
  apt:
    pkg:          "{{ item }}"
    state:        present
    update_cache: true
  with_items:
    - apt-transport-https
    - ca-certificates
    - curl
    - software-properties-common

- name: Install the GPG key
  shell: curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

- name: Add Docker repository
  apt_repository:
    repo: deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable
    state: present

- name: Install Docker
  apt:
    pkg:          docker-ce=17.03.0~ce-0~ubuntu-xenial
    state:        present
    update_cache: yes

- name: Install Docker compose
  shell: >
    curl -L https://github.com/docker/compose/releases/download/1.13.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose &&
    sudo chmod +x /usr/local/bin/docker-compose
  become: true
```

[See my full ansible examples repository for more](https://github.com/wakproductions/ansible-examples)
