// (c) Copyright 1992, Qualitas, Inc. All Rights Reserved
//
// dpmierr.h - error codes for DPMIhost class
//
// The error code definitions are limited to essentially success and failure,
// since not all hosts support the DPMI 1.0 error return set.
//
typedef enum DPMIerrorCode {
	DPMIok,
	DPMInotOk
} DPMIerr;