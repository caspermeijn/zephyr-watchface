FROM gitpod/workspace-full-vnc

ENV CUSTOM_XVFB_WxHxD=320x240x16

# https://docs.zephyrproject.org/latest/getting_started/index.html
# Install dependencies
RUN sudo apt update && \
      cd /tmp && \
      wget https://apt.kitware.com/kitware-archive.sh && \
      sudo bash kitware-archive.sh && \
      sudo apt install -y --no-install-recommends git cmake ninja-build gperf \
        ccache dfu-util device-tree-compiler wget \
        python3-dev python3-pip python3-setuptools python3-tk python3-wheel xz-utils file \
        make gcc gcc-multilib g++-multilib libsdl2-dev  && \
      cmake --version && \
      python3 --version && \
      dtc --version

ENV PATH=~/.local/bin:$PATH
ENV PYTHONUSERBASE=
# Get Zephyr and install Python dependencies
RUN pip3 install --user -U west && \
      echo 'export PATH=~/.local/bin:$PATH' >> ~/.bashrc &&\
      ~/.local/bin/west init ~/zephyrproject && \
      cd ~/zephyrproject && \
      ~/.local/bin/west update && \
      ~/.local/bin/west zephyr-export && \
      pip3 install --user -r ~/zephyrproject/zephyr/scripts/requirements.txt && \
      ~/.local/bin/west --version

# Install a Toolchain
RUN cd /tmp && \
    wget --no-verbose https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.13.1/zephyr-sdk-0.13.1-linux-x86_64-setup.run && \
    chmod +x zephyr-sdk-0.13.1-linux-x86_64-setup.run && \
    ./zephyr-sdk-0.13.1-linux-x86_64-setup.run -- -d ~/zephyr-sdk-0.13.1