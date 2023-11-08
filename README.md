# HomeLab Design & Instructions
Working towards building a automated home lab deployement with DevOps principles in mind.  

High level overview of what is encompased. 

## Containers (docker)

### - ParrotHTB-Linux-Dockerfile  
A simple dockerfile which allows you to build a _docker image_ starting from the latest official one of **Kali Linux** and including some useful tools.  
#### Included tools  
These are the main **tools** which are included:
- Kali Linux [Top 10](https://tools.kali.org/kali-metapackages) metapackage
- exploitdb , man-db , dirb , nikto , wpscan , uniscan , tor , proxychains  
Note that you can _add/modify/delete_ configuration files by doing the related changes in the dockerfile.
#### Other useful things  

  

## Usage  
In order to build an _image_ from this dockerfile, just go on the folder where it is located and simple open your favourite **Terminal**, typing as follows:
- Automated  
 -- Login to server and pull this repo to relevant dirctory. eg. git pull https://github.com/craigrachow/HomeLab
 -- python or bash ./build homelab.py

- Manual  
 -- Login to server and pull this repo to relevant dirctory. eg. git pull https://github.com/craigrachow/HomeLab
 -- Install Docker 
  ```sh
  docker build [-t your_image_name] .
  ```




##### More info

Check out [Kali Linux on a Docker container: the easiest way](https://tsumarios.github.io/blog/2022/09/17/kali-linux-docker-container/) for more detailed info.

#### Contacts  
- Email: 
- LinkedIn: 
- Website

_If you want to support me, I would be grateful ❤️_  
<a href="https://www.buymeacoffee.com/craigrachow" target="_blank"><img
        src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="40"></a>

### Todos  
- Add some more useful tools, languages.

**Enjoy!**

Getting Parrot HTB to work
1. containers/parrotHTB.sh -deploy container via dockerfile and yaml. befroe so make ./parrotHTB folder for persistent storage. 
2. software/prepserver.sh - install docker and cli and any other apps
3. storage/


---------- PRACTICE --------------

variables:
  IMAGE_NAME: hello-world
  IMAGE_TAG: hello-world-1.0
  
build-image:
  image: docker-latest
  services:
   - docker-latest-dind
variables:
  DOCKER_TLS_CERTDIR: "/certs"
before_script: 
  - apt-get update && apt-get install make
script:
  - docker build -t $IMAGE_NAME:$IMAGE_TAG .
  - docker push $IMAGE_NAME:$IMAGE_TAG
    
