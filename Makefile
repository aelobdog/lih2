all: ./sitefl/sitefl.go
	cd sitefl && \
		rm index.html index.stfl LICENSE README.md && \
		go build sitefl.go
