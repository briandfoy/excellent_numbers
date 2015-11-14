PERL=perl5.22.0

all: README.pod

excellent.txt: FORCE
	@ sort -n -u $@ > $@.sorted
	@ mv $@.sorted $@
	@ echo "There are \c"
	@ wc -l $@ | ${PERL} -ne 'print /(\d+)/'
	@ echo " excellent numbers"

README.pod: excellent.txt
	@ ${PERL} -Mlib=lib tools/put_nums_in_readme

FORCE:
