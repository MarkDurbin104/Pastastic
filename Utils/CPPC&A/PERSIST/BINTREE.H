///////////////////////////////////////////////////////////////
//  PERSISTENCE LIBRARY
//      bintree.h
//
//      Binary tree class for Persistent objects
//
//      Copyright 1992 Scott Robert Ladd
//      All rights reserved
///////////////////////////////////////////////////////////////

#ifndef BINTREE_H
#define BINTREE_H

#include "persist.h"

//-------------------------------------------------------------
//  TreeErrorBase
//      Base class providing error handling for Tree classes
//-------------------------------------------------------------

class TreeErrorBase
    {
    public:
        static void SetErrOut(const ErrReporter & er);

    protected:
        static ErrReporter * ErrOut;

        static void ReportError();
    };

//-------------------------------------------------------------
//  TreeNode
//      A node in a binary tree
//-------------------------------------------------------------

struct TreeNode : public TreeErrorBase
    {
    // links
    TreeNode  * Less;
    TreeNode  * Greater;
    TreeNode  * Parent;

    // contents
    KeyString Key;
    DataBlock Data;

    // constructor
    TreeNode(const KeyString & k, 
             const DataBlock & db);

    // copy constructor
    TreeNode(const TreeNode & node);

    // assignment operator
    void operator = (const TreeNode & node);
    };

//-------------------------------------------------------------
//  BinaryTree
//      A basic binary tree
//-------------------------------------------------------------

typedef Boolean (* TreeEnumFunc)(const KeyString & str,
                                 const DataBlock & db);

class BinaryTree : public TreeErrorBase
    {
    public:
        // constructor
        BinaryTree();

        // copy constructor
        BinaryTree(const BinaryTree & tree);

        // destructor
        ~BinaryTree();

        // assignment opeartor
        void operator = (const BinaryTree & tree);

        // store an item
        Boolean Insert(const KeyString & key, 
                       const DataBlock & db);

        // delete an item
        Boolean Delete(const KeyString & key);

        // retrieve an item
        DataBlock LookUp(const KeyString & key) const;

        // traverse entire tree, calling a function for each node
        void Enumerate(TreeEnumFunc func);

    protected:
        // data members
        TreeNode *   Root;     // root node
        TreeEnumFunc EnumFunc; // pointer to enumeration function

        // recursive copy function
        void RecursiveCopy(TreeNode * node);

        // recursive traversal function
        void RecurseTraverse(TreeNode * node);

        // recursive deletion function
        void RecursiveDelete(TreeNode * node);
    };

#endif
