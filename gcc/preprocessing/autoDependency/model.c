//
// Created by wein on 5/2/18.
//

#include <stdlib.h>

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
    for (int i = 0; i < item->numChildren; ++i) {
        deleteItem(item->children[i]);
    }
    free(item);
}

void setRoot(struct Model *model, struct ModelItem *root) {
    if (model->root) {
        deleteItem(model->root);
    }
    model->root = root;
}
