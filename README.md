Role Name
=========

sets up local hashi setup

Requirements
------------

homebrew 

How to use it
------------
* run role
* run the launchctl commands printed in the debug output during execution (use unload to stop service)
* open docker and set it up
* add `/usr/local/var/nomad` to the docker shared folders
* reboot to make sure DNS works
* things should resolve as `myapp.service.dc1.consul`
* consul gui: http://consul.service.dc1.consul:8500/
* nomad gui: http://nomad.service.dc1.consul:4646/
* fabio gui: http://fabio.service.dc1.consul:9998/
* due to nomad + mac docker limition.. view logs via `docker logs containername`
* see `hashiparty.sh` in role `files/` for a start stop script
* See notes in tips and tricks at bottom of page

Using with fabio
---------------
fabio http runs on port 9999... all your url prefixes will require 9999...
easiset thing to do is for any app.. `urlprefix-myapp.service.dc1.consul:9999/`   then you can use DNS for http proxying and stop guessing ports


Role Variables
--------------
see `defaults.yml`


Example Playbook
----------------
`ansible-playbook workstation.yml -K`  (a few steps sudo, but dont run all as sudo)

```

- hosts: workstation

  tasks: 
    - name: setup hashi stack
      include_role:
        name: mac-hashi-local-dev
```

Example Nomad Job
----------------
running is as easy as
`nomad run jenkins.nomad`

jenkins.nomad
```
job "jenkins" {
  meta {
  	version = "20180515-02"
  }
  datacenters = ["dc1"]
  type = "service"
  update {
    max_parallel = 1
    min_healthy_time = "10s"
    healthy_deadline = "8m"
    auto_revert = false
    canary = 0
  }
  group "jenkins" {
    count = 1
    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }
    task "jenkins" {
      driver = "docker"
      env {
        JENKINS_HOME = "/var/jenkins_home"
        HUDSON_HOME = "/var/jenkins_home"
     }
      config {
        image = "tomcat"
        force_pull = true
        port_map {
          jenkins_http = 8080
          jenkins-jlnp = 35123
        }
        volumes = [ 
        "local:/usr/local/tomcat/webapps"
	]
    #    args = [ "jenkins", "-dataclean","-config", "${NOMAD_TASK_DIR}/config.json" ]
      }
      resources {
        cpu    = 2000 # 500 MHz
        memory = 800 # 256MB
        network {
          mbits = 20
          port "jenkins_http" {}
          port "jenkins_jnlp" {
            static = "35123"
          }
        }
      }
      artifact {
        source      = "http://mirrors.jenkins.io/war-stable/latest/jenkins.war"
        destination = "local/"
      }
      service {
        name = "jenkins"
        tags = ["urlprefix-jenkins.service.dc1.consul:9999/"]
        port = "jenkins_http"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
#      service {
#        name = "jenkins-jnlp"
#        tags = ["jenkins"]
#        port = "jenkins_jnlp"
#        check {
#          name     = "alive"
#          type     = "tcp"
#          interval = "10s"
#          timeout  = "2s"
#        }
#      }
    }
  }
}
```

## Tips and Tricks ##

### nomad customization ###

Basic config defaults are provided at command line execution, but addtional nomad json configurations can be placed in `/usr/local/var/nomad/config`.

### OSXKEYCHAIN GOTCHA ###

you will probably need to remove the following line from `$HOME/.docker/config.json`
```
 "credSstore" : "osxkeychain",
```
or find the nomad fix and let me know!   In the meantime, nomad has a a config.json file pointing to config.json for docker auth

License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
