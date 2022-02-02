ROOT=.

# the latest stable version is:
STABLE= 7.81.0
RELDATE = "5th of January 2022"
# The planned *next* release is:
NEXTDATE = "2nd of March 2022"

# generated file with binary package stats
STAT = packstat.t

# generated file with release info (STABLE and RELDATE)
RELEASE = release.t

include mainparts.mk
include setup.mk

MAINPARTS += _menu.html alert.t
FCPP_OPTS = -DSHOW_ALERT

PAGES= \
 404.html \
 about.html \
 book.html \
 changes.html \
 dashboard.html \
 dashboardd.html \
 dashboard5.html \
 dashboard1.html \
 donation.html \
 download.html \
 foot.html \
 gethelp.html \
 head.html \
 index.html \
 info \
 libs.html \
 mirrors.html \
 news.html \
 newslog.html \
 oldnews.html \
 search.html \
 sponsors.html \
 support.html \
 web-editing.html \
 download/index.html

all: $(PAGES)
	cd ca && make
	cd docs && make
	cd libcurl && make
	cd mail && make
	cd mirror && make
	cd rfc && make
	cd dev && make
	cd windows && make
	cd tiny && make
	cd logo && make

head.html: _head.html $(MAINPARTS)
	$(ACTION)

404.html: _404.html $(MAINPARTS)
	$(ACTION)

donation.html: _donation.html docs/_menu.html $(MAINPARTS)
	$(ACTION)

search.html: _search.html $(MAINPARTS) sitesearch.t
	$(ACTION)

web-editing.html: _web-editing.html $(MAINPARTS)
	$(ACTION)

foot.html: _foot.html $(MAINPARTS)
	$(ACTION)

index.html: _index.html $(MAINPARTS) release.t packstat.t
	$(ACTION)

download/index.html: release.t mk-download.pl
	./mk-download.pl > $@

newslog.html: _newslog.html $(MAINPARTS)
	$(ACTION)

news2.html: _news2.html $(MAINPARTS)
	$(ACTION)

news.html: news2.html newslog.html
	rm -f $@
	./filter.pl < $< > $@

olddata.html: _oldnews.html $(MAINPARTS)
	$(ACTION)

oldnews.html: olddata.html
	rm -f $@
	./filter.pl < $< > $@

info: _info packstat.t
	$(ACTION)

$(RELEASE): Makefile
	@echo "fixing $(RELEASE)"
	@echo "#define __STABLE $(STABLE)" >$(RELEASE)
	@echo "#define __RELDATE $(RELDATE)" >>$(RELEASE)
	@echo "#define __NEXTDATE $(NEXTDATE)" >>$(RELEASE)
	@echo "#define __STABLETAG $(STABLE)" | sed 's/\./_/g' >> $(RELEASE)

$(STAT): download.html Makefile
	@echo "fixing $(STAT)"
	@echo "#define __CURR "`grep -c "^.tr.class=.latest" $<` >$(STAT)
	@echo "#define __PACKS `grep -c \"^<tr c\" $<`" >>$(STAT)

download.html: _download.html $(MAINPARTS) $(RELEASE) dl/files.html
	$(ACTION)

download2.html: _download2.html $(MAINPARTS) $(RELEASE) dl/files.html
	$(ACTION)

dl/files.html: dl/data/databas.db
	cd dl; make

changes.html: _changes.html docs/_menu.html $(MAINPARTS)
	$(ACTION)

gethelp.html: _gethelp.html $(MAINPARTS)
	$(ACTION)

book.html: _book.html $(MAINPARTS)
	$(ACTION)

mirrors.html: _mirrors.html $(MAINPARTS)
	$(ACTION)

about.html: _about.html docs/_menu.html $(MAINPARTS)
	$(ACTION)

sponsors.html: _sponsors.html docs/_menu.html $(MAINPARTS)
	$(ACTION)

dashboardd.html: _dashboardd.html dash.gen dashboard.t $(MAINPARTS)
	$(ACTION)

dashboard.html: _dashboard.html dash.gen dashboard.t $(MAINPARTS)
	$(ACTION)

dashboard5.html: _dashboard5.html dash.gen dashboard.t $(MAINPARTS)
	$(ACTION)

dashboard1.html: _dashboard1.html dash.gen dashboard.t $(MAINPARTS)
	$(ACTION)

libs.html: _libs.html $(MAINPARTS)
	$(ACTION)

support.html: _support.html $(MAINPARTS)
	$(ACTION)

perlcheck:
	@for f in `git ls-files | grep '\.pl$$' `; do perl -c $$f; done

full: all
	@cd libcurl; make

clean:
	rm -f *~ $(PAGES)
	cd docs && make clean
	cd libcurl && make clean
	cd mail && make clean
	cd mirror && make clean
	cd rfc && make clean
	cd dev && make clean
	cd tiny && make clean
