#!/usr/bin/env bash

# source:
# youtube
# UPEvent - GCC and Makefiles

# file extension for expanded (pre-processed) file is
# general .i (but you don't really ever see these
# files)

# void setRoot(struct Model *model, struct ModelItem *root) {
#
## 42 "model.c" 3 4
#   ((
## 42 "model.c"
#   model
## 42 "model.c" 3 4
#   ) ? (void) (0) : __assert_fail (
## 42 "model.c"
#   "model"
## 42 "model.c" 3 4
#   , "model.c", 42, __PRETTY_FUNCTION__))
## 42 "model.c"
#                      ;
#    printf("set root");
function expandGCC() {
    gcc -DDEBUG -E -o /tmp/_.i model.c
    echo "
/////////// GCC preprocessor ///////////
"
    cat /tmp/_.i
}

# CLANG's expanded code looks nicer
#
# void setRoot(struct Model *model, struct ModelItem *root) {
#    ((model) ? (void) (0) : __assert_fail ("model", "model.c", 43, __PRETTY_FUNCTION__));
#    printf("set root: %d", ((model->numItems) > (999) ? (model->numItems) : (999)));
#    if (model->root) {
#        deleteItem(model->root);
#    }
#    model->root = root;
#}
function expandCLANG() {
    clang -DDEBUG -E -o /tmp/_.i model.c
    echo "
/////////// clang preprocessor ////////////
"
    cat /tmp/_.i
}

expandGCC
( which clang >/dev/null 2>&1 && expandCLANG )

exit 0
