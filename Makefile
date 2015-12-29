PERL=perl5.22.0
PERL5OPT=-Mlib=lib
FILES=excellent.txt README.pod bA162700.txt primes.txt

all: README.pod bA162700.txt primes.txt tweet
	git commit -m 'Update excellent number list' ${FILES}
	git push --all
	@ ${PERL} tools/get_tweets

bA162700.txt: excellent.txt
	@ echo "# A162700 (b-file created by https://github.com/briandfoy/excellent_numbers)" > $@
	@ ${PERL} -ne 'print qq($$. $$_)' excellent.txt >> $@

excellent.txt: FORCE
	${PERL} tools/scan_output output c
	@ sort -n -u $@ > $@.sorted
	@ mv $@.sorted $@
	@ echo "There are \c"
	@ wc -l $@ | ${PERL} -ne 'print /(\d+)/'
	@ echo " excellent numbers"

README.pod: excellent.txt
	@ ${PERL} tools/put_nums_in_readme

primes.txt: excellent.txt tools/primes
	@ ${PERL} tools/primes

tweet: FORCE
	@ ${PERL} tools/get_tweets

FORCE:
