//
// Created by wein on 5/2/18.
//

#include <stdlib.h>

// variadic pronounces [vari'adic]

void BEGIN_SOURCE() {}

#define MAX2(a, b) ((a) > (b) ? (a) : (b))
#ifdef DEBUG
    #include <assert.h>
    #include <stdio.h>
    #define DEBUG_PRINT(...) printf(__VA_ARGS__)
    #define DEBUG_ASSERT(expr) assert(expr)
#else
    #define DEBUG_PRINT(...)
    #define DEBUG_ASSERT(expr)
#endif

struct ModelItem;

struct ModelItem {
    void *data;
    struct ModelItem **children;
    int numChildren;
};

struct Model {
    struct ModelItem *root;
    int numItems;
};

void deleteItem(struct ModelItem *item) {
    DEBUG_ASSERT(item);
    DEBUG_PRINT("delete item");
    for (int i = 0; i < item->numChildren; ++i) {
        deleteItem(item->children[i]);
    }
    free(item);
}

void setRoot(struct Model *model, struct ModelItem *root) {
    DEBUG_ASSERT(model);
    DEBUG_PRINT("set root: %d", MAX2(model->numItems, 999));
    if (model->root) {
        deleteItem(model->root);
    }
    model->root = root;
}

void END_SOURCE() {}

