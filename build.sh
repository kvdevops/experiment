#!/bin/bash

# We assume the following programs/tools exist:
# gmake, wget, git, bunzip2, PyPy (Python 2.7), Java, patch, timeout, mktemp, flex, cc, ant


missing=0
check_for () {
    which $1 > /dev/null 2> /dev/null
    if [ $? -ne 0 ]; then
        echo "Error: can't find $1 binary"
        missing=1
    fi
}

check_for make
check_for git
check_for wget
check_for bunzip2
check_for java
check_for javac
check_for patch
check_for timeout
check_for mktemp
check_for flex
check_for cc
check_for ant
check_for parallel
check_for tar
check_for bc

if [ $missing -eq 1 ]; then
    exit 1
fi


which pypy > /dev/null 2> /dev/null
if [ $? -eq 0 ]; then
    PYTHON=`which pypy`
else
    check_for python
    PYTHON=`which python`
fi

export PYTHON 

java -version 2>&1 | tail -n 1 | grep "OpenJDK .*Server VM (build [a-zA-Z0-9.\-]*, mixed mode)" > /dev/null 2> /dev/null
if [ $? -ne 0 ]; then
    cat << EOF
Warning: incorrect version of Java detected. Expected:
  OpenJDK Server VM (build ..., mixed mode)
You should download the correct version and put it in your PATH.
EOF
    echo -n "Continue building anyway? [Ny] "
    read answer
    case "$answer" in
        y | Y) ;;
        *) exit 1;;
    esac
fi

$PYTHON -V 2>&1 | egrep -o '[0-9].[0-9]' > /dev/null 2> /dev/null
if [ $? -ne 0 ]; then
    cat << EOF
Warning: incorrect version of Python detected. Expected:
  Python 2.7 or above
You should download the correct version and put it in your PATH.
EOF
    echo -n "Continue building anyway? [Ny] "
    read answer
    case "$answer" in
        y | Y) ;;
        *) exit 1;;
    esac
fi

if [ $# -eq 0 ]; then
    wrkdir=`pwd`
elif [ $# -eq 1 ]; then
    wrkdir=$1
    mkdir -p $wrkdir
else
    echo "$0 [<full path to working directory>]"
    exit 1
fi
echo -e "\\n===> Working in $wrkdir\\n"

# Download ACCENT tools -- accent, amber and entire parser

echo -e "\\n===> Fetching ACCENT tools\\n"

cd $wrkdir
wget http://accent.compilertools.net/accent.tar
tar xf accent.tar
cd accent/accent
./build
[ ! -f accent ] && echo "ACCENT build has failed. Check in $wrkdir/accent" && exit 1
# patch amber
patch -b -p0 $wrkdir/accent/amber/amber.c < $cwd/patches/amber.patch || exit $?
# patch entire
patch -b -p0 $wrkdir/accent/entire/entire.c < $cwd/patches/entire.c.patch || exit $?

# Download SinBAD
# git@github.com:nvasudevan/sinbad.git

echo -e "\\n===> Fetching SinBAD tool\\n"

cd $wrkdir
git clone http://github.com/nvasudevan/sinbad.git 
cd sinbad
[ ! -f $wrkdir/sinbad/src/sinbad ] && echo "SinBAD tool didn't download. Check in $wrkdir/sinbad" && exit 1


# Download ACLA

echo -e "\\n===> Fetching ACLA tool\\n"

cd $wrkdir
mkdir ACLA
cd ACLA
wget http://www.brics.dk/grammar/dist/grammar-all.jar
wget http://www.brics.dk/~amoeller/automaton/automaton-1.11-8.tar.gz
tar -zxf automaton-1.11-8.tar.gz
wget http://www.brics.dk/grammar/grammar-2.0-4.tar.gz
tar -zxf grammar-2.0-4.tar.gz
mv automaton-1.11/src/dk/brics/automaton grammar-2.0/src/dk/brics/
cd grammar-2.0
patch -b -p0 build.xml < $cwd/patches/acla.build.xml.patch || exit $?
patch -b -p0 src/dk/brics/grammar/ambiguity/AmbiguityAnalyzer.java < $cwd/patches/acla.patch || exit $?
patch -b -p0 src/dk/brics/grammar/ambiguity/ApproximationStrategy.java < $cwd/patches/ApproximationStrategy.java.patch || exit $?
patch -b -p0 src/dk/brics/grammar/ambiguity/RegularApproximation.java < $cwd/patches/RegularApproximation.java.patch || exit $?
patch -b -p0 src/dk/brics/grammar/operations/AutomataOperations.java < $cwd/patches/AutomataOperations.java.patch || exit $?
patch -b -p0 src/dk/brics/automaton/BasicOperations.java < $cwd/patches/BasicOperations.java.patch || exit $?
patch -b -p0 src/dk/brics/grammar/main/Main.java < $cwd/patches/Main.java.patch || exit $? 
patch -b -p0 src/dk/brics/grammar/main/MainCommandLine.java < $cwd/patches/MainCommandLine.java.patch || exit $?
patch -b -p0 src/dk/brics/grammar/ambiguity/AmbiguityAnalyzer.java < $cwd/patches/AmbiguityAnalyzer.java.patch || exit $?
patch -b -p0 src/dk/brics/automaton/Automaton.java < $cwd/patches/Automaton.java.patch || exit $?
patch -b -p0 src/dk/brics/grammar/main/MainServlet.java < $cwd/patches/MainServlet.java.patch || exit $?
patch -b -p0 src/dk/brics/grammar/main/MainGUI.java < $cwd/patches/MainGUI.java.patch || exit $?
patch -b -p0 src/dk/brics/grammar/ambiguity/RegularApproximation2.java < $cwd/patches/RegularApproximation2.java.patch || exit $?
patch -b -p0 src/dk/brics/grammar/ambiguity/TerminalApproximation.java < $cwd/patches/TerminalApproximation.java.patch || exit $?

# patch automaton src too
ant
[ ! -f dist/grammar.jar ] && echo "ACLA didn't compile. Check in $wrkdir/ACLA" && exit 1
# repackage acla
cd ..
mkdir repackage
cd repackage
jar -xf ../grammar-all.jar
cp META-INF/MANIFEST.MF META-INF/MANIFEST.MF.orig
jar -xf ../grammar-2.0/dist/grammar.jar 
mv META-INF/MANIFEST.MF.orig META-INF/MANIFEST.MF
jar cmf META-INF/MANIFEST.MF ../grammar.modified.jar *
[ ! -f $wrkdir/ACLA/grammar.modified.jar ] && echo "ACLA can't be patched. Please check in $wrkdir/ACLA" && exit 1


# Download AmbiDexter

echo -e "\\n===> Fetching AmbiDexter tool\\n"

cd $wrkdir
git clone http://github.com/cwi-swat/ambidexter.git
# latest commits are related to jdk 8 and that leads to compilation issues
cd ambidexter
git reset --hard 241fbf5d3e928ec032607f850a8d00223f54ec31
mkdir -p build/META-INF
echo "Main-Class: nl.cwi.sen1.AmbiDexter.Main" > build/META-INF/MANIFEST.MF
patch -b -p0 src/nl/cwi/sen1/AmbiDexter/derivgen/ParallelDerivationGenerator.java < $cwd/patches/AmbiDexter.patch || exit $?
cd src
javac nl/cwi/sen1/AmbiDexter/*.java || exit $?
find . -type f -name "*.class" | cpio -pdm ../build/
cd ../build
jar cmf META-INF/MANIFEST.MF AmbiDexter.jar nl
[ ! -f $wrkdir/ambidexter/build/AmbiDexter.jar ] && echo "AmbiDexter failed to build. Check in $wrkdir/ambidexter" && exit $?

echo "===> build complete"

