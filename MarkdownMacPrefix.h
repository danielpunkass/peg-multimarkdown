#include <stdlib.h>
#include <stdio.h>

#import "GLibCocoaBridge.h"
#import "markdown_lib.h"

#define link PEG_link
#import "markdown_peg.h"

// peg
#define Class PEG_Class
#import "tree.h"
#undef Class

