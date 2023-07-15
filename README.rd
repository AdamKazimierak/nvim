Domhyslnie Ubuntu na instaluje nvim 0.6.0. Ta wersja jest zbyt stara i nalezy zainstalowac nowsza aby konfiguracja dzialala.
For me the solution was build from source:

Install dependencies:

sudo apt-get install ninja-build gettext cmake unzip curl

2. Clone Neovim repo:

git clone https://github.com/neovim/neovim.git

cd neovim

3. Checkout stable version (0.9.1):

git checkout v0.9.1

4. Build and install:

make CMAKE_BUILD_TYPE=Release

sudo make install




# CTRL+W S/V - split screen horizontally/vertically
