# ContactsCleaner

## Background

I recently discovered a bug in local (ie, iTunes or Finder) synchronization of contacts between macOS and iOS: if any record has a relation field with either a "son" or "daughter" label, it causes the whole synchronization to fail, and one of these messages appears in the Console:

```
default	17:40:25.631217+0100	AddressBookSync	[0x7fc65c407d60] |ISyncSession|Error| ISyncSession record validation failure: Value son pushed for enumeration property type on com.apple.contacts.Related Name is not an allowed value.
default	17:40:25.631650+0100	AddressBookSync	AddressBookSync (client id: com.apple.AddressBook) error: Exception running AddressBookSync: ISyncSession record validation failure: Value son pushed for enumeration property type on com.apple.contacts.Related Name is not an allowed value.
```

or:

```
default	17:43:48.921860+0100	AddressBookSync	[0x7fe2dc411860] |ISyncSession|Error| ISyncSession record validation failure: Value daughter pushed for enumeration property type on com.apple.contacts.Related Name is not an allowed value.
default	17:43:48.922344+0100	AddressBookSync	AddressBookSync (client id: com.apple.AddressBook) error: Exception running AddressBookSync: ISyncSession record validation failure: Value daughter pushed for enumeration property type on com.apple.contacts.Related Name is not an allowed value.
```

This behavior wasn't present in macOS 10.12 (Sierra). I was able to reproduce it with macOS 10.14.6 and 10.15.2. It doesn't seem to be related to the version of iOS.

I submitted a bug report. Meanwhile, there is an easy workaround: replace all "son" and "daughter" labels in related names with "child". This is exactly the purpose of this tool.

## Usage

This tool is provided as a Swift Package to build a command-line utility.

### Build

To build:

```
cd ContactsCleaner
swift build
```

### Check Database

To check whether records are affected, without modifying the Contacts database:

```
.build/debug/ContactsCleaner
```

This command displays the number of affected records, and a list with name, organization, and related names for each of them.

### Update Database

To update the affected records:

```
.build/debug/ContactsCleaner update
```

This command replaces all "son" and "daughter" related name labels in the Contacts database with "child".

## Disclaimer

Use at your own risk.

