///////////////////////////////////////////////////////////////
//  PERSISTENCE LIBRARY
//      bintree.cxx
//
//      Binary tree class for Persistent objects
//
//      Copyright 1992 Scott Robert Ladd
//      All rights reserved
///////////////////////////////////////////////////////////////

#include "stddef.h"
#include "stdlib.h"
#include "bintree.h"

//-------------------------------------------------------------
//  TreeErrorBase
//      Base class providing error handling for Tree classes
//-------------------------------------------------------------

ErrReporter * TreeErrorBase::ErrOut = NULL;

void TreeErrorBase::ReportError()
    {
    if (ErrOut != NULL)
        ErrOut->Fatal("memory allocation failure in tree");
    }

void TreeErrorBase::SetErrOut(const ErrReporter & er)
    {
    if (ErrOut != NULL)
        delete ErrOut;

    ErrOut = new ErrReporter(er);
    }

//-------------------------------------------------------------
//  TreeNode
//      A node in a binary tree
//-------------------------------------------------------------

// constructor
TreeNode::TreeNode(const KeyString & k, 
                   const DataBlock & db)
    : Key(k), Data(db)
    {
    Parent  = NULL;
    Less    = NULL;
    Greater = NULL;
    }

// copy constructor
TreeNode::TreeNode(const TreeNode & node)
    : Key(node.Key), Data(node.Data)
    {
    Parent  = node.Parent;
    Less    = node.Less;
    Greater = node.Greater;
    }

// assignment operator
void TreeNode::operator = (const TreeNode & node)
    {
    Parent  = node.Parent;
    Less    = node.Less;
    Greater = node.Greater;

    Key     = node.Key;
    Data    = node.Data;
    }

//-------------------------------------------------------------
//  BinaryTree
//      A basic binary tree
//-------------------------------------------------------------

// constructor
BinaryTree::BinaryTree()
    {
    Root = NULL;
    }

// copy constructor
BinaryTree::BinaryTree(const BinaryTree & tree)
    {
    Root = NULL;

    RecursiveCopy(tree.Root);
    }

// destructor
BinaryTree::~BinaryTree()
    {
    RecursiveDelete(Root);
    }

// assignment opeartor
void BinaryTree::operator = (const BinaryTree & tree)
    {
    RecursiveDelete(Root);

    Root = NULL;

    RecursiveCopy(tree.Root);
    }

// store an item
Boolean BinaryTree::Insert(const KeyString & key, 
                           const DataBlock & db)
    {
    Boolean result = BOOL_FALSE;

    TreeNode * newnode = new TreeNode(key,db);

    if (newnode == NULL)
        ReportError();

    if (Root == NULL)
        {
        Root   = newnode;
        result = BOOL_TRUE;
        }
    else
        {
        TreeNode * node = Root;

        while (node != NULL)
            {
            // replace a duplicate key
            if (newnode->Key == node->Key)
                {
                // copy links from old node
                newnode->Less    = node->Less;
                newnode->Greater = node->Greater;
                newnode->Parent  = node->Parent;

                // is node the root?
                if (node == Root)
                    Root = newnode; // replace root node
                else
                    {
                    // replace node with newnode in parent
                    if (node->Parent->Less == node)
                        node->Parent->Less = newnode;
                    else
                        node->Parent->Greater = newnode;    
                    }

                // delete old node
                delete node;

                result = BOOL_TRUE;

                break;
                }

            if (newnode->Key < node->Key)
                {
                if (node->Less == NULL)
                    {
                    // insert node
                    node->Less = newnode;
                    newnode->Parent = node;
                    result = BOOL_TRUE;
                    break;
                    }
                else // move to next node
                    node = node->Less;
                }
            else
                {
                if (node->Greater == NULL)
                    {
                    // insert node
                    node->Greater = newnode;
                    newnode->Parent = node;
                    result = BOOL_TRUE;
                    break;
                    }
                else // move to next node
                    node = node->Greater;
                }
            }
        }

    return result;
    }

// delete an item
Boolean BinaryTree::Delete(const KeyString & key)
    {
    TreeNode * node = Root;

    while (node != NULL)
        {
        if (key == node->Key)
            break;

        if (key < node->Key)
            node = node->Less;
        else
            node = node->Greater;
        }

    if (node == NULL)
        return BOOL_FALSE;

    if (node->Greater == NULL)
        {
        if (node->Less == NULL)
            {
            if (node == Root)
                Root = NULL; // tree is now empty!
            else
                {
                // remove leaf node
                if (node->Parent->Less == node)
                    node->Parent->Less = NULL;
                else
                    node->Parent->Greater = NULL;
                }
            }
        else // node has a "lesser" subtree
            {
            if (node == Root)
                Root = node->Less;
            else
                {
                // splice "less" subtree
                if (node->Parent->Less == node)
                    node->Parent->Less = node->Less;
                else
                    node->Parent->Greater = node->Less;
                }
            }
        }
    else // node has a "greater" subtree
        {
        if (node->Less == NULL)
            {
            if (node == Root)
                Root = node->Greater;  // new root node
            else
                {
                // splice "greater" subtree
                if (node->Parent->Less == node)
                    node->Parent->Less = node->Greater;
                else
                    node->Parent->Greater = node->Greater;
                }
            }
        else // deleted node has two decendants... ugh!
            {
            // look for immediate successor
            TreeNode * successor = node->Greater;

            while (successor->Less != NULL)
                successor = successor->Less;

            // unlink successor from tree
            if (successor->Parent->Less == successor)
                successor->Parent->Less = successor->Greater;
            else
                successor->Parent->Greater = successor->Greater;

            // copy data from successor to deleted node
            node->Key  = successor->Key;
            node->Data = successor->Data;

            // update parent links in children
            if (successor->Greater != NULL)
                successor->Greater->Parent = node;

            // set successor to be deleted
            node = successor;
            }
        }

    // delete node that was removed
    delete node;
    
    return BOOL_TRUE;
    }

// retrieve an item
DataBlock BinaryTree::LookUp(const KeyString & key) const
    {
    TreeNode * node = Root;

    while (node != NULL)
        {
        if (key == node->Key)
            break;

        if (key < node->Key)
            node = node->Less;
        else
            node = node->Greater;
        }

    if (node == NULL)
        return NULL_BLOCK;
    else
        return node->Data;
    }

// traverse entire tree, calling a function for each node
void BinaryTree::Enumerate(TreeEnumFunc func)
    {
    EnumFunc = func;

    RecurseTraverse(Root);
    }

// recursive copy function
void BinaryTree::RecursiveCopy(TreeNode * node)
    {
    if (node != NULL)
        {
        Insert(node->Key,node->Data);

        RecursiveCopy(node->Less);
        RecursiveCopy(node->Greater);
        }
    }

// recursive traversal method
void BinaryTree::RecurseTraverse(TreeNode * node)
    {
    if (node != NULL)
        {
        RecurseTraverse(node->Less);
        EnumFunc(node->Key,node->Data);
        RecurseTraverse(node->Greater);
        }
    }

// recursive deletion method
void BinaryTree::RecursiveDelete(TreeNode * node)
    {
    if (node != NULL)
        {
        RecursiveDelete(node->Less);
        RecursiveDelete(node->Greater);

        delete node;
        }
    }

