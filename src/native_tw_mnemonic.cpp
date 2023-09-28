#include "TWMnemonic.h"

#ifndef EXPORT_API
#define EXPORT_API \
    extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

/// Determines whether a BIP39 English mnemonic phrase is valid.
///
/// \param mnemonic Non-null BIP39 english mnemonic
/// \return true if the mnemonic is valid, false otherwise
EXPORT_API
bool TWMnemonicIsValidNative(TWString* mnemonic)
{
    return TWMnemonicIsValid(mnemonic);
}

/// Determines whether word is a valid BIP39 English mnemonic word.
///
/// \param word Non-null BIP39 English mnemonic word
/// \return true if the word is a valid BIP39 English mnemonic word, false otherwise
EXPORT_API
bool TWMnemonicIsValidWordNative(TWString* word)
{
    return TWMnemonicIsValidWord(word);
}

/// Return BIP39 English words that match the given prefix. A single string is returned, with space-separated list of words.
///
/// \param prefix Non-null string prefix
/// \return Single non-null string, space-separated list of words containing BIP39 words that match the given prefix.
EXPORT_API
TWString* TWMnemonicSuggestNative(TWString* prefix)
{
    return TWMnemonicSuggest(prefix);
}
