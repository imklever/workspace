function nav_scroll()
{
    body_var=window.getComputedStyle(document.body,null);
    //console.log("helo"+body_var);
    /*
       for( i in body_var)
       {
       console.log(i+":"+body_var[i]);
       }
     */
    //console.log(window.getComputedStyle(document.body,null).offset);
    var body_top=(window.getComputedStyle(document.body,null).top);//�����ľ���,���붥���ľ���
    console.log("body_top = "+body_top);

    var nav_left  = document.getElementById("nav_left");	//��ȡ��������id
    //nav_left = window.getComputedStyle(nav_left,null);

    if( body_top > 100 )  //�������������100pxʱִ������Ķ���
    {
        nav_left.style.top=0;
    }else
    {
        nav_left.style.top=body_top;
    }
    /**/
}