FROM centos:centos7

LABEL maintainer="Ruijia Wang <Ruijia.Wang@qiagen.com>"

#### install centos libs
RUN yum install -y epel-release && yum update -y	
RUN yum install -y gcc gcc-c++ bison pkgconfig libtool libstdc++-devel \
        glib2-devel gettext make freetype-devel fontconfig-devel \
       libXft-devel libpng-devel libjpeg-devel libtiff-devel giflib-devel \
        ghostscript-devel libexif-devel libX11-devel  libgdiplus libungif libgif-dev wget which tar zip bzip2
		
#### install Mono 4.0.4
RUN wget -c "http://download.mono-project.com/sources/mono/mono-4.0.4.1.tar.bz2"
RUN tar jxvf mono-4.0.4.1.tar.bz2
RUN cd  mono-4.0.4 && ./configure --prefix=/opt/mono-4.0.4 --with-large-heap=yes && make && make install		
RUN rm -rf mono-4.0.4
RUN rm -rf mono-4.0.4.1.tar.bz2
RUN mkdir oshell
RUN cd oshell/ && touch oshell.exe && wget -c  "http://omicsoft.com/software_update/OmicsoftUpdater.exe"  && /opt/mono-4.0.4/bin/mono ./OmicsoftUpdater.exe
#RUN sh -c "ulimit -n 65536 && exec su $LOGNAME"
#RUN sh -c "ulimit -u 65536 && exec su $LOGNAME"

#### config
####<dllmap dll="gdiplus.dll" target="/lib64/libgdiplus.so.0"/>
RUN mv /opt/mono-4.0.4/etc/mono/config /opt/mono-4.0.4/etc/mono/config.bak  
RUN awk -v line=$(wc -l < /opt/mono-4.0.4/etc/mono/config.bak) -v val='<dllmap dll="gdiplus.dll" target="/lib64/libgdiplus.so.0"/>' 'FNR==(line){print val} 1' /opt/mono-4.0.4/etc/mono/config.bak > /opt/mono-4.0.4/etc/mono/config
RUN chmod 755 -R /oshell/
RUN mkdir -p /opt/omicsoft/Scripts
RUN mkdir -p /opt/omicsoft/Logs	
RUN chmod 755 -R /opt/omicsoft/
ENV PATH="/opt/mono-4.0.4/bin/:/oshell:/opt/omicsoft/Scripts:${PATH}"	

#### Update and test
RUN mono /oshell/OmicsoftUpdater.exe
RUN mono /oshell/OmicsoftUpdater.exe
RUN mono /oshell/oshell.exe --version > version.log
