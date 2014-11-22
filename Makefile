CLEANDIR=bin/clean
INFECTEDDIR=bin/infected
HTMLDIR=html
LOG=build.log

default: clean

clean:
	rm -rf ${CLEANDIR}/*.png ${INFECTEDDIR}/* ${HTMLDIR}/* ${LOG}
 
