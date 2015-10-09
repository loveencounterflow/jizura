

- [jizura](#jizura)
	- [Overview of Unicode CJK Characters by Regions](#overview-of-unicode-cjk-characters-by-regions)
		- [TexLive installation](#texlive-installation)
			- [TexLive installation (OSX)](#texlive-installation-osx)
			- [TexLive installation (Ubuntu)](#texlive-installation-ubuntu)

> **Table of Contents**  *generated with [DocToc](http://doctoc.herokuapp.com/)*


# jizura
CJK character information

## Overview of Unicode CJK Characters by Regions

![](https://github.com/loveencounterflow/jizura/raw/master/texts/unicode-cjk-chrs-by-regions/euler-venn-diagram-cjk-usage-by-region.png)


### TexLive installation

#### TexLive installation (OSX)


#### TexLive installation (Ubuntu)

While there's a lot of software that you can and should install on Debianish /
Ubuntish systems, there's also a number of software titles you should definitely
*not* install that way; examples include

* NodeJS, which will always be outdated when installed via `apt`, will get
  the wrong name (`nodejs` instead of `node`), and will not give you the opportunity
  to just-so switch between versions as you can with `n` or `nvm`;

* Open/LibreOffice; as [I argue in the Readme about Writing macros for LibreOffice with
  Coffeescript](https://github.com/loveencounterflow/coffeelibre#remarks-for-running-aoo-on-ubuntu),
  OpenOffice in Ubuntu is annoyingly broken and somewhat hard to replace with
  a reasonable LibreOffice installation;

* and, sadly, TeX Live. Turns out while you can choose between a 'basic' and a 'full'
  installation of TeX Live using `apt-get`, neither will be 'as full' as the one
  that'd get with the official TeX Live download. Case in point: a command like
  `tlmgr info xcolor` is going to fail miserably with an `apt` installation
  of TeX Live, and [there seems to be no easy way to fix that](http://tex.stackexchange.com/questions/137428/tlmgr-cannot-setup-tlpdb).

I recommend using https://github.com/scottkosty/install-tl-ubuntu instead; you can just clone
the repo to some `tmp` location and run the install script with `sudo ./install-tl-ubuntu`,
very simple.




