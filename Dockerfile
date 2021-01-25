FROM rikorose/gcc-cmake:gcc-10
# if we want to install via apt

RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get install -y vim
RUN apt-get install -y gdb

RUN apt-get install -y libgtest-dev
RUN cd /usr/src/gtest && cmake CMakeLists.txt
RUN cd /usr/src/gtest && make
RUN cd /usr/src/gtest && cp *.a /usr/lib

RUN apt-get install -y openjdk-11-jre

RUN mkdir -p /usr/local/src
COPY quickfix.zip /usr/local/src
RUN cd /usr/local/src && unzip quickfix.zip
RUN cd /usr/local/src && rm -f quickfix.zip

RUN mkdir -p /usr/local/src/protobuf-3.14.0
COPY protoc-3.14.0-linux-x86_64.zip /usr/local/src/protobuf-3.14.0
RUN cd /usr/local/src/protobuf-3.14.0 && unzip protoc-3.14.0-linux-x86_64.zip
RUN cd /usr/local/src/protobuf-3.14.0 && rm -f protoc-3.14.0-linux-x86_64.zip
RUN ln -s /usr/local/src/protobuf-3.14.0/bin/protoc /usr/local/bin/protoc

RUN mkdir -p /work/testplan
RUN cd  /work/testplan
RUN git clone https://github.com/Morgan-Stanley/testplan.git
RUN apt-get install -y python3-pip
RUN pip3 install virtualenv

RUN python3 -m pip install --user https://github.com/Morgan-Stanley/testplan/archive/master.zip

RUN cd /testplan && pip3 install -r requirements-basic.txt
RUN cd /testplan && python3 setup.py develop --no-deps

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get  update
RUN apt-get install -y yarn

RUN cd /testplan/testplan/web_ui/testing && yarn install --production
RUN cd /testplan/testplan/web_ui/testing && yarn add levenary

RUN pip3 install boltons
RUN pip3 install ipaddress
RUN pip3 install matplotlib
RUN pip3 install scipy
RUN pip3 install sphinx
RUN pip3 install sphinx-rtd-theme

RUN pip3 uninstall schema -y

RUN pip3 install schema==0.6.8
RUN pip3 install Werkzeug==0.16.1

RUN sed -i 's/OverrideMeOrThereWillBeABuildError/http:\/\/localhost:4000\/api\/v1\/interactive\//' /testplan/testplan/web_ui/testing/.env 
RUN cd /testplan && python3 /testplan/install-testplan-ui --verbose
RUN cp -Rf /testplan/testplan/web_ui/testing/* /root/.local/lib/python3.7/site-packages/testplan/web_ui/testing
