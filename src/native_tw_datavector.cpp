#include "TWDataVector.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

/// Creates a Vector of Data.
///
/// \note Must be deleted with \TWDataVectorDelete
/// \return a non-null Vector of Data.
EXPORT_API
struct TWDataVector* TWDataVectorCreateNative()
{
    return TWDataVectorCreate();
}

/// Creates a Vector of Data with the given element
///
/// \param data A non-null valid block of data
/// \return A Vector of data with a single given element
EXPORT_API
struct TWDataVector* TWDataVectorCreateWithDataNative(TWData* data)
{
    return TWDataVectorCreateWithData(data);
}

/// Delete/Deallocate a Vector of Data
///
/// \param dataVector A non-null Vector of data
EXPORT_API
void TWDataVectorDeleteNative(struct TWDataVector* dataVector)
{
    TWDataVectorDelete(dataVector);
}

/// Add an element to a Vector of Data. Element is cloned
///
/// \param dataVector A non-null Vector of data
/// \param data A non-null valid block of data
/// \note data input parameter must be deleted on its own
EXPORT_API
void TWDataVectorAddNative(struct TWDataVector* dataVector, TWData* data)
{
    TWDataVectorAdd(dataVector, data);
}

/// Retrieve the number of elements
///
/// \param dataVector A non-null Vector of data
/// \return the size of the given vector.
EXPORT_API
size_t TWDataVectorSizeNative(const struct TWDataVector* dataVector)
{
    return TWDataVectorSize(dataVector);
}

/// Retrieve the n-th element.
///
/// \param dataVector A non-null Vector of data
/// \param index index element of the vector to be retrieved, need to be < TWDataVectorSize
/// \note Returned element must be freed with \TWDataDelete
/// \return A non-null block of data
EXPORT_API
TWData* TWDataVectorGetNative(const struct TWDataVector* dataVector,
                              size_t                     index)
{
    return TWDataVectorGet(dataVector, index);
}
