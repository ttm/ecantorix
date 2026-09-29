# Renders a song for the music Python package, which writes achant.abc and
# achant.conf into a directory beside this one (cache/) and runs make there.
ECANTORIX = ../ecantorix.pl
# Where espeak says its data is, rather than where one Linux layout puts it.
ESPEAK_DATA ?= $(shell espeak --version | sed -n 's/.*Data at: //p')
# The extra voices control files include by relative path.
EXTRAVOICES ?= ../examples/extravoices

ALL = \
      achant.wav \

all: $(ALL)
all: .FORCE

.FORCE:

extravoices:
	cp -R $(EXTRAVOICES) extravoices

espeak-data: extravoices
	$(RM) -r espeak-data
	mkdir espeak-data
	cp -R $(ESPEAK_DATA)/* espeak-data/
	cp -R ~/espeak-data/* espeak-data/ || true
	cp extravoices/* espeak-data/voices/\!v

%.mid: %.abc
	abc2midi $< 0 -o $@

# Redirected rather than piped through tee: through a pipe, make saw tee's
# exit status and carried on when the script failed.
%.mmp %.ass: %.mid %.conf espeak-data
	mkdir -p cache
	$(ECANTORIX) -C $*.conf -c cache -O mmp -o $*.mmp $< > $*.ass

%.wav %.ass: %.mid %.conf espeak-data
	mkdir -p cache
	$(ECANTORIX) -C $*.conf -c cache -O wav -o $*.wav $< > $*.ass

%-xon.mid %.ass: %.mid %.conf espeak-data
	mkdir -p cache
	$(ECANTORIX) -C $*.conf -c cache -O mid --output-mid-prefix=vocals: -o $*-xon.mid $< > $*.ass

clean:
	$(RM) -r espeak-data extravoices cache
	$(RM) *.wav *.mid *.mmp *.ass
