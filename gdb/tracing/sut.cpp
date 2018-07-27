// source
// found from wt codebase

#include <vector>
#include <memory>
#include <cstdint>

// forward declarations
class Data;
class SystemData;
using PData = std::shared_ptr<Data>;
using PSystemData = std::shared_ptr<SystemData>;
using Store = std::vector<PData>;
using Children = std::vector<PSystemData>;

// declarations
class Data {
public:
    PData getElement(const uint32_t i);
    void createElement();
    uint32_t numElements();
private:
    Store m_elements;
};


class SystemData {
public:
    SystemData(Data& parent);
    PData getElement(const uint32_t i);
private:
    Data* m_parent;
    Store m_elements;
};

// Data class implementations
PData Data::getElement(const uint32_t i) {
    return m_elements[i];
}

void Data::createElement() {
    auto _ = std::make_shared<Data>();
    m_elements.push_back(_);
}

uint32_t Data::numElements() {
    return m_elements.size();
}

// SystemData class implementations
SystemData::SystemData(Data& parent)
    : m_parent(&parent),
      m_elements(parent.numElements(), 0x0) {
}

PData SystemData::getElement(const uint32_t i) {
    return m_elements[i];
}

// mock up some ui actions, such as drag and drops
PSystemData createSystemData(Data& d) {
    d.createElement();
    d.createElement();

    PSystemData psd(new SystemData{d});  // sd allocate two element slots

    d.createElement();
    d.createElement();  // sd's parent, a Data object has add
                        // two more elements
                        // if sd.getElement is called with 3
                        // it crashes.

    return psd;
}

void accessSystemData(PSystemData psd) {
    // why it crashes????
    psd->getElement(3);
}

int main() {
    Data d;
    auto psd = createSystemData(d);
    accessSystemData(psd);
    return 0;
}
