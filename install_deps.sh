#!/bin/bash
# Compilation flags
: ${CFLAGS="-fPIC"}
: ${CXX_FLAGS=${CFLAGS}}

DEP_INSTALL_DIR=install

LIBXML_URI=http://xmlsoft.org/sources/libxml2-2.9.8.tar.gz
FREETYPE_URI=https://download.savannah.gnu.org/releases/freetype/freetype-2.9.tar.gz
ICU_URI=http://download.icu-project.org/files/icu4c/62.1/icu4c-62_1-src.tgz

mkdir -p $DEP_INSTALL_DIR

cd $DEP_INSTALL_DIR

if [[ "$OSTYPE" == "linux-gnu" ]]; then
if ! [ -x "$(command -v autoreconf)" ]; then
        sudo apt-get install autoconf
        fi
        ICU_CONFIG="Linux"
        LIB_INSTALL="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
        # Mac OSX
        if ! [ -x "$(command -v autoreconf)" ]; then
            brew install autoreconf
        fi
        ICU_CONFIG="MacOSX"
        LIB_INSTALL="mac"
elif [[ "$OSTYPE" == "cygwin" ]]; then
        # POSIX compatibility layer and Linux environment emulation for Windows
        ICU_CONFIG="Cygwin"
        LIB_INSTALL="windows"
#elif [[ "$OSTYPE" == "msys" ]]; then
        # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
#elif [[ "$OSTYPE" == "win32" ]]; then
        # I'm not sure this can happen.
#elif [[ "$OSTYPE" == "freebsd"* ]]; then
        # ...
#else
        # Unknown.
fi

echo "$LIB_INSTALL"

echo 'Installing libxml2.'
#
rm -f libxml2-2.9.8.tar.gz
wget $LIBXML_URI

tar xvf libxml2-2.9.8.tar.gz

cd libxml2-2.9.8

autoreconf

#Once configure is produced :

./configure --disable-dependency-tracking --without-python --without-lzma --without-iconv --without-zlib

make

cd ..

echo 'libxml2 installation is finished.'


echo 'Installing freetype.'

rm -f freetype-2.9

wget $FREETYPE_URI

tar xvf freetype-2.9.tar.gz

cd freetype-2.9

mkdir _build && cd _build

cmake -G "Unix Makefiles" ../ "-DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=true"  -DCMAKE_DISABLE_FIND_PACKAGE_HarfBuzz=TRUE -DFT_WITH_ZLIB=OFF -DFT_WITH_BZIP2=OFF -DFT_WITH_PNG=OFF

make

cd ../..

echo 'Freetype installation is finished.'


echo 'Installing ICU.'

rm -f icu4c-62_1-src

wget $ICU_URI

tar xvf icu4c-62_1-src.tgz

cd icu/source && mkdir lib && mkdir bin

chmod +x runConfigureICU configure install-sh

./runConfigureICU $ICU_CONFIG --enable-static --disable-shared

make

cd ../..

echo 'ICU installation is finished.'

cd ..

echo 'Installing zlib and png.'

cd libs/image/zlib/src && cmake "-DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=true" && make && cd -
cd libs/image/png/src && cmake "-DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=true" && make && cd -

echo 'zlib and png installation is finished.'

echo 'Copying libraries into their corresponding location.'

cp libs/image/zlib/src/libzlib.a libs/image/zlib/$LIB_INSTALL/
cp libs/image/png/src/libpng.a libs/image/png/$LIB_INSTALL/
cp $DEP_INSTALL_DIR/freetype-2.9/_build/libfreetype.a libs/freetype/$LIB_INSTALL/
cp $DEP_INSTALL_DIR/libxml2-2.9.8/.libs/libxml2.a libs/libxml/$LIB_INSTALL/
cp $DEP_INSTALL_DIR/icu/source/lib/libicuuc.a libs/icu/$LIB_INSTALL/
cp $DEP_INSTALL_DIR/icu/source/stubdata/libicudata.a libs/icu/$LIB_INSTALL/

rm -rf $DEP_INSTALL_DIR

echo 'done.'