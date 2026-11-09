#include <owl.h>
#include "gpadmwin.h"

class Gpad : public TApplication
{
    public:
        Gpad(LPSTR n,HINSTANCE i,HINSTANCE p,LPSTR cl,int cs) : 
            TApplication(n,i,p,cl,cs) {}
        virtual void InitMainWindow();
};
void Gpad::InitMainWindow()
{
    MainWindow=new Mainwin(Name,"MENU_1");
}
int PASCAL WinMain(HINSTANCE hi,HINSTANCE hpi,LPSTR cl,int ncs)
{
    Gpad app("Untitled",hi,hpi,cl,ncs);
    app.Run();
    return app.Status;
}
