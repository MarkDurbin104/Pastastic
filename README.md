# Pastastic

Old Pascal projects — a small personal history, 1992 to 2018.

This is an **archive for reference only**. Nothing here is maintained, supported,
or expected to compile. It is kept because it is a record of how things were
built at the time, not because anyone should build on it.

> **Do not rely on this code.** It targets compilers, operating systems and
> databases that are long gone (Turbo Pascal, Delphi 1–7, BDE, Windows 95
> through Server 2003). It has not been reviewed against anything resembling
> current practice, and some of it was abandoned mid-thought. Read it as
> history. Do not ship it.

## What's here

Five trees, recovered from old drives and grouped by origin. Roughly 1,500
Pascal/Delphi source files.

| Folder | Era | Pascal files | What it is |
|---|---|---|---|
| [`Utils/`](Utils/) | 1992–97 | 163 | The oldest material. Turbo Pascal and Delphi 1/2. |
| [`Postal/`](Postal/) | 2002–05 | 908 | Postal counter-automation system. The bulk of the archive. |
| [`Cykor/`](Cykor/) | 2003–08 | 384 | Windows services, COM/ActiveX, early web services. |
| [`Rumford/`](Rumford/) | 2009 | 70 | Last substantial Delphi work. |
| [`IppDiag/`](IppDiag/) | 2018 | 4 | A single diagnostic tool. The newest thing here. |

### `Utils/` — 1992–97

Where it starts. `ASMCODE/CHAPT12/` is Turbo Pascal linked against external
assembly (`{$L TestAlt}`) — book exercises, the earliest files in the archive.

The rest is early Delphi, in 8.3 filenames: `CPPGEN` (a C++ source generator),
`GENGRAPH`, `RESXPLOR` (a resource explorer), `DOCU`/`DOCU2` (documentation
tooling), `ERPOLY` (polygon work), `MDIAPP`, `WORLD`, plus small utilities —
`Phone`, `Todo`, barcode printing. There is a `compass/` subsystem covering
email, shutdown and keyboard hooks, and a `upu/` tree with a fuller
`UserInterfaceServices` layer.

Much of this is experiment and scaffolding rather than finished work.

### `Postal/` — 2002–05

The largest piece: the software of **Postal Solutions Limited (PSL)**, a family
of products for post office automation rather than a single application.
`Source/` holds all 908 Pascal files, organised into a deliberate structure —
`RunTime/`, `Packages/`, `Base Components/`, `Component Designer/`,
`Utility Components/`, `Support Applications/`, `Setup Builder/`, `Test Code/`.

The naming runs to constellations and elements:

| Name | What it is |
|---|---|
| **Corvus** | Branch counter automation — the foundation components |
| **Shirika** | The communication infrastructure underneath all the products |
| **Indigo3** | Money order management framework |
| **Osmium** | Payments management framework |
| **Trazar** | Domestic mail tracking |
| **Pyxis** | P.O. Box management |
| **PhilIPA** | Philatelic management |
| **Solo** | Small office data entry |
| **IPA** | Integrated Postal Architecture — the overarching concept |
| **CDT** | The toolchain: code and documentation generators, test programs, dummy hardware drivers |

Alongside these: IPA Central Consolidation and Central Inventory, and IPS
Integration — the link into the UPU's international system, which is also why
there is a `upu/` tree over in `Utils/`.

So `Corvus` is the foundation the counter applications are built on, `Shirika`
is the messaging layer beneath everything, and `Indigo3`/`Osmium` are separate
frameworks for money orders and payments. They are layers, not aliases.

Not all of them are *here*, though. Corvus runs through 218 source files, with
`CorvusVCL` as the component package and `CorvusReportShare` as its shared-memory
channel; Osmium has its own application under
`Source/Support Applications/Osmium/` and an `OsmiumSupportU.pas`; Shirika and
Indigo3 appear throughout the messaging and money-order code. Trazar, PhilIPA
and Solo left no source behind in this archive.

The shape worth noting is in `Source/RunTime/`: one shared `MainFU.pas` with a
thin `.dpr` wrapper per customer over it — fourteen of them, across Africa, the
Middle East, South Asia and a few island postal services. Each build is a few
lines of configuration over a common core, which was the whole point of the
Corvus foundation.

Underneath: COM/ActiveX (`ComServ2`, `GPCSGUID`, `GPCSBase_TLB`), BDE database
access (`DBTables`), UDP messaging, CRC32, custom VCL controls. Supporting
applications cover the operational edges — `PO Box Manager`, `Report Generator`,
`Router Monitor`, `MSG Store Viewer`, `Migration Tools`, `Clean Machine`,
`IntegrityCheck`, `Licence`, scale and OCR and receipt-printer integration.

`Source.rar` and the reference material alongside it (`Messages/`, `Images/`,
`IDS/`, `RDO/`) are kept as they were found.

### `Cykor/` — 2003–08

Windows service and integration work, preserved under its original relative
paths because the same projects appear in more than one backup.

- `Work/DelphiWorkspace/` — `VU.iTService` (a Windows service with its own test
  harness), `BASimulator`, `BEEPService`, `HTTPServer`, `Base64Decode`,
  `Reboot`, `TrayIcon`, and a Gecko-based browser wrapping the Mozilla SDK
- `Work/Source/` — `AXPanel`, `Echo`, `FlashPlayer`, `MailFileParse`, `Comprress`
- `Work/WebServices/EchoService/` — a SOAP service in three parts: CGI, Web App
  Debugger, and client
- `Keep/IDS/` — the IDS interface-definition system (`IDSParse`, `IDSEdit`,
  `UseCase`), tied back to `Postal/`
- `Documents/Borland Studio Projects/` — Delphi 8 and Delphi.NET experiments
- `Backup/Copied Across/` — an older mirror of `Work/DelphiWorkspace`, kept
  deliberately so the duplication is visible rather than silently resolved

Only the Pascal-bearing subtrees were taken; the drive they came from was a
general backup of unrelated material.

### `Rumford/` — 2009

The last substantial Delphi work, and the most modern in structure — it was
under Subversion (metadata removed on import).

`trunk/Bridge/Delphi/` holds the interesting parts: `VU.iTService` again, now
with a comment explaining the Windows 2003 `StartServiceCtrlDispatcher` /
`CoRegisterClassObject` ordering problem and `DelayInitialize` as the way
around it. Alongside it: `UDPDLL`, a SQLite test harness, `EnumWindows`,
`GetFileList`, `proxy`, `Ding`. `trunk/Client/` and `trunk/Almanac/` carry the
client side, mixing in ActionScript and .NET.

### `IppDiag/` — 2018

One small Delphi project, nine years after the rest: a TCP/IP diagnostic tool
for PC-DMIS machine interfaces, built on Indy (`IdTCPClient`/`IdTCPServer`)
with a command-list UI for sending and replaying sequences. Eight files,
`Unit1.pas` doing all the work.

## Notes on the archive itself

**Compiled output is kept.** `.exe`, `.dll`, `.dcu` and `.obj` files are
committed on purpose. For code this old the binaries are part of the record —
in several cases they are the only evidence that something built and ran. They
are not here to be used.

**Original bytes are preserved.** `.gitattributes` sets `* -text`, so git does
not normalise line endings. These files should still match the originals
byte-for-byte; CRLF, trailing `^Z`, and DOS-era encodings are intentional.

**Excluded:** Delphi IDE state (`.dsk`, `.local`, `.identcache`) and numbered
editor backups (`.~1~`, `.~2~`, …) — about 740 files of no historical value.
See [`.gitignore`](.gitignore).

**Trimmed on import:** `Postal/` originally carried ~4 GB of business documents
and two large archives (`Drive_E.zip`, `Data.rar`) that contained no source.
Those stay on the original drive. Everything removed was verified present there
first.

**Duplication is left in place.** Where the same project survives in several
backups, the copies are kept rather than merged — which backup something came
from is itself part of the history.

## Provenance

Written by me and my teams, across several employers and about two decades.
The companies behind this work — Postal Solutions Limited and Cykor Systems —
are both long gone.

Kept as a personal record of what was built, nothing more.
