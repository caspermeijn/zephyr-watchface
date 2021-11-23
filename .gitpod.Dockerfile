FROM gitpod/workspace-full-vnc

ENV CUSTOM_XVFB_WxHxD=800x600x16

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

# Get Zephyr and install Python dependencies
RUN cd /tmp && \
      sudo pip3 install -U west && \
      west init ~/zephyrproject && \
      cd ~/zephyrproject && \
      west update && \
      west zephyr-export && \
      sudo pip3 install -r ~/zephyrproject/zephyr/scripts/requirements.txt && \
      west --version

# Install a Toolchain
RUN cd /tmp && \
    wget https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.13.1/zephyr-sdk-0.13.1-linux-x86_64-setup.run && \
    chmod +x zephyr-sdk-0.13.1-linux-x86_64-setup.run && \
    ./zephyr-sdk-0.13.1-linux-x86_64-setup.run -- -d ~/zephyr-sdk-0.13.1