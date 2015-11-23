PERL=perl5.22.0
FILES=excellent.txt README.pod bA162700.txt

all: README.pod bA162700.txt
	git commit -m 'Update excellent number list' ${FILES}
	git push --all

bA162700.txt: excellent.txt
	@ echo "# A162700 (b-file created by https://github.com/briandfoy/excellent_numbers)" > $@
	@ ${PERL} -ne 'print qq($$. $$_)' excellent.txt >> $@

excellent.txt: FORCE
	@ sort -n -u $@ > $@.sorted
	@ mv $@.sorted $@
	@ echo "There are \c"
	@ wc -l $@ | ${PERL} -ne 'print /(\d+)/'
	@ echo " excellent numbers"

README.pod: excellent.txt
	@ ${PERL} -Mlib=lib tools/put_nums_in_readme

FORCE:
