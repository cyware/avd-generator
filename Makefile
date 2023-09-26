md-update-deps:
	cd docGen && go get github.com/khulnasoft-lab/defsec \
	&& go mod tidy

md-build: 
	cd docGen && go build -o ../generator .

md-test:
	cd docGen && go test -v ./...

md-clean:
	rm -f ./generator

md-clone-all:
	# git clone git@github.com:khulnasoft-lab/avd.git avd-repo/
	git clone git@github.com:khulnasoft-lab/vuln-list.git avd-repo/vuln-list
	git clone git@github.com:khulnasoft-lab/kube-hunter.git avd-repo/kube-hunter-repo
	git clone git@github.com:khulnasoft-lab/kube-bench.git avd-repo/kube-bench-repo
	git clone git@github.com:khulnasoft-lab/chain-bench.git avd-repo/chain-bench-repo
	git clone git@github.com:khulnasoft-lab/cloud-security-remediation-guides.git avd-repo/remediations-repo
	git clone git@github.com:khulnasoft-lab/tracker.git avd-repo/tracker-repo
	git clone git@github.com:khulnasoft-lab/defsec.git avd-repo/defsec-repo
	git clone git@github.com:khulnasoft-lab/cloudsploit.git avd-repo/cloudsploit-repo

update-all-repos:
	cd avd-repo/vuln-list && git pull
	cd avd-repo/kube-hunter-repo && git pull
	cd avd-repo/kube-bench-repo && git pull
	cd avd-repo/chain-bench-repo && git pull
	cd avd-repo/remediations-repo && git pull
	cd avd-repo/tracker-repo && git pull
	cd avd-repo/defsec-repo && git pull
	cd avd-repo/cloudsploit-repo && git pull

sync-all:
	rsync -av ./ avd-repo/ --exclude=.idea --exclude=go.mod --exclude=go.sum --exclude=nginx.conf --exclude=main.go --exclude=main_test.go --exclude=README.md --exclude=avd-repo --exclude=.git --exclude=.gitignore --exclude=.github --exclude=content --exclude=docs --exclude=Makefile --exclude=goldens

md-generate:
	cd avd-repo && ./generator

nginx-start:
	-cd avd-repo/docs && nginx -p . -c ../../nginx.conf

nginx-stop:
	-cd avd-repo/docs && nginx -s stop -p . -c ../../nginx.conf

nginx-restart:
	make nginx-stop nginx-start

hugo-devel:
	hugo server -D --debug

hugo-clean:
	cd avd-repo && rm -rf docs

hugo-generate: hugo-clean
	cd avd-repo && hugo --destination=docs
	echo "avd.khulnasoft.com" > avd-repo/docs/CNAME

simple-host:
	cd avd-repo && python3 -m http.server

copy-assets:
	cp -R avd-repo/remediations-repo/resources avd-repo/docs/resources
	touch avd-repo/docs/.nojekyll

build-all-no-clone: md-clean md-build sync-all md-generate hugo-generate copy-assets nginx-restart
	echo "Build Done, navigate to http://localhost:9011/ to browse"

build-all: md-clean md-build md-clone-all sync-all md-generate hugo-generate copy-assets nginx-restart
	echo "Build Done, navigate to http://localhost:9011/ to browse"

compile-theme-sass:
	cd themes/khulnasoftblank/static/sass && sass avdblank.scss:../css/avdblank.css && sass avdblank.scss:../css/avdblank.min.css --style compressed
