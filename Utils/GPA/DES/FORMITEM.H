#ifndef FORMITEM_H
#define FORMITEM_H
//-------------------------------------------------------------------------
class FormItem {                                // Form Item Class
    private :
        INT xpos;                               // the x co-ordinate
        INT ypos;                               // the y co-ordinate
        INT ident;                              // the unique identifier
        INT order;                              // the processing order
//        Prompt prompt;                        // the help prompt
        String action;                          // the associated action
    public :
        virtual void Display(void);             // display the item
        virtual void Report (void);             // report on the item
        virtual void Process(void);             // process the item
};
//-------------------------------------------------------------------------
class FormField : FormItem {                    // Form Field Class
    private :
        INT attr;                               // the field attribute
        INT size;                               // the field size
    public :
};
//-------------------------------------------------------------------------
class TFormField : FormField {                  // Text Form Field Class
    private :
        String text;                            // the text
    public :
        virtual void Display(void);             // display the item
        virtual void Report (void);             // report on the item
        virtual void Process(void);             // process the item
};
//-------------------------------------------------------------------------
class DFormField : FormField {                  // Display Form Field Class
    private :
        String format;                          // the input format
        String variable;                        // the attached variable
        String storefield;                      // the attached store field
    public :
        virtual void Display(void);             // display the item
        virtual void Report (void);             // report on the item
        virtual void Process(void);             // process the item
        virtual void FormatOutput(void);        // Output formatting
};
//-------------------------------------------------------------------------
class PFormItem : FormItem {                    // Picture Form Item Class
    private :
        Image image;                            // the picture
    public :
        virtual void Display(void);             // display the item
};
//-------------------------------------------------------------------------

#endif // ndef FORMITEM_H
