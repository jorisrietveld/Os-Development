#																			#
# 	Author: Joris Rietveld <jorisrietveld@gmail.com>						#
#																			#
#	Description:															#
#	Make file for assembling, linking and running assembler programs.		#
#																			#
.DEFAULT_GOAL:=help
BASE_NAME:=hello1


all: assemble link run
	@echo "====================================================================
	@echo "= 						x64
	@echo "
    @echo "
    @echo "
    @echo "

assemble: $(BASE_NAME).asm ## Assemle the code to binary instuctions.
	@echo "Assebling..."
	@nasm -f elf64 -o $(BASE_NAME).o $(BASE_NAME).asm
	@echo "\e[92mSuccessfully assembled $(BASE_NAME).asm to $(BASE_NAME).0\e[39m"

link: $(BASE_NAME).o ## Assemle the code to binary instuctions.
	@echo "Assebling..."
	@ld -o $(BASE_NAME) $(BASE_NAME).o
	@echo "\e[92mSuccessfully linked $(BASE_NAME).0 to $(BASE_NAME)\e[39m"

run: $(BASE_NAME) ## Run the compiled binary.
	./hello1

.PHONY: help

help:
	# Some black magic for documenting make instructions with dubble hashtags
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'



