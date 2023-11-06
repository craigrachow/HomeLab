# HomeLab Design & Instructions
Working towards building a automated home lab deployement with devops principles in mind.  

High level overview of what is encompased. 

# Containers (docker)

# Parrot HTB-Linux-Dockerfile  
A simple dockerfile which allows you to build a _docker image_ starting from the latest official one of **Kali Linux** and including some useful tools.

## Included tools  
These are the main **tools** which are included:

- Kali Linux [Top 10](https://tools.kali.org/kali-metapackages) metapackage
- exploitdb
- man-db
- dirb
- nikto
- wpscan
- uniscan
- tor
- proxychains

Note that you can _add/modify/delete_ configuration files by doing the related changes in the dockerfile.

### Other useful things


### Usage

In order to build an _image_ from this dockerfile, just go on the folder where it is located and simple open your favourite **Terminal**, typing as follows:

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

<a href="https://www.buymeacoffee.com/tsumarios" target="_blank"><img
        src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="40"></a>

### Todos

- Add some more useful tools, languages.

**Enjoy!**
