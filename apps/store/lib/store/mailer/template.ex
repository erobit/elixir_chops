defmodule Store.Mailer.Template do
  def feedback_template(customer_details, feedback) do
    """
    <table align="center" border="0" cellspacing="0" cellpadding="0" width="600" style="width:600px;">
    <tr>
        <td align="center" valign="top" width="600" style="width:600px;">
          <![endif]-->
          <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" class="templateContainer">
              <tr>
                <td valign="top" class="bodyContainer">
                    <table border="0" cellpadding="0" cellspacing="0" width="100%" class="mcnTextBlock" style="min-width:100%;">
                      <tbody class="mcnTextBlockOuter">
                          <tr>
                            <td valign="top" class="mcnTextBlockInner" style="padding-top:9px;">
                                <!--[if mso]>
                                <table align="left" border="0" cellspacing="0" cellpadding="0" width="100%" style="width:100%;">
                                  <tr>
                                      <![endif]-->
                                      <!--[if mso]>
                                      <td valign="top" width="600" style="width:600px;">
                                        <![endif]-->
                                        <table align="left" border="0" cellpadding="0" cellspacing="0" style="max-width:100%; min-width:100%;" width="100%" class="mcnTextContentContainer">
                                            <tbody>
                                              <tr>
                                                  <td valign="top" class="mcnTextContent" style="padding-top:0; padding-right:18px; padding-bottom:9px; padding-left:18px;">
                                                    <h2 style="text-align: center;">Customer Feedback</h2>
                                                    <div style="text-align: center;">#{
      customer_details
    }</div>
                                                    <div style="text-align: center;">#{feedback}</div>
                                                  </td>
                                              </tr>
                                            </tbody>
                                        </table>
                                        <!--[if mso]>
                                      </td>
                                      <![endif]-->
                                      <!--[if mso]>
                                  </tr>
                                </table>
                                <![endif]-->
                            </td>
                          </tr>
                      </tbody>
                    </table>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
        </table>
    """
  end

  def link_template(title, subtitle, link_text, link_url) do
    """
    <table align="center" border="0" cellspacing="0" cellpadding="0" width="600" style="width:600px;">
    <tr>
        <td align="center" valign="top" width="600" style="width:600px;">
          <![endif]-->
          <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" class="templateContainer">
              <tr>
                <td valign="top" class="bodyContainer">
                    <table border="0" cellpadding="0" cellspacing="0" width="100%" class="mcnTextBlock" style="min-width:100%;">
                      <tbody class="mcnTextBlockOuter">
                          <tr>
                            <td valign="top" class="mcnTextBlockInner" style="padding-top:9px;">
                                <!--[if mso]>
                                <table align="left" border="0" cellspacing="0" cellpadding="0" width="100%" style="width:100%;">
                                  <tr>
                                      <![endif]-->
                                      <!--[if mso]>
                                      <td valign="top" width="600" style="width:600px;">
                                        <![endif]-->
                                        <table align="left" border="0" cellpadding="0" cellspacing="0" style="max-width:100%; min-width:100%;" width="100%" class="mcnTextContentContainer">
                                            <tbody>
                                              <tr>
                                                  <td valign="top" class="mcnTextContent" style="padding-top:0; padding-right:18px; padding-bottom:9px; padding-left:18px;">
                                                    <h2 style="text-align: center;">#{title}</h2>
                                                    <div style="text-align: center;">#{subtitle}</div>
                                                  </td>
                                              </tr>
                                            </tbody>
                                        </table>
                                        <!--[if mso]>
                                      </td>
                                      <![endif]-->
                                      <!--[if mso]>
                                  </tr>
                                </table>
                                <![endif]-->
                            </td>
                          </tr>
                      </tbody>
                    </table>
                    <table border="0" cellpadding="0" cellspacing="0" width="100%" class="mcnDividerBlock" style="min-width:100%;">
                      <tbody class="mcnDividerBlockOuter">
                          <tr>
                            <td class="mcnDividerBlockInner" style="min-width: 100%; padding: 18px 18px 0px;">
                                <table class="mcnDividerContent" border="0" cellpadding="0" cellspacing="0" width="100%" style="min-width:100%;">
                                  <tbody>
                                      <tr>
                                        <td>
                                            <span></span>
                                        </td>
                                      </tr>
                                  </tbody>
                                </table>
                                <!--            
                                  <td class="mcnDividerBlockInner" style="padding: 18px;">
                                  <hr class="mcnDividerContent" style="border-bottom-color:none; border-left-color:none; border-right-color:none; border-bottom-width:0; border-left-width:0; border-right-width:0; margin-top:0; margin-right:0; margin-bottom:0; margin-left:0;" />
                                  -->
                            </td>
                          </tr>
                      </tbody>
                    </table>
                    <table border="0" cellpadding="0" cellspacing="0" width="100%" class="mcnTextBlock" style="min-width:100%;">
                      <tbody class="mcnTextBlockOuter">
                          <tr>
                            <td valign="top" class="mcnTextBlockInner" style="padding-top:9px;">
                                <!--[if mso]>
                                <table align="left" border="0" cellspacing="0" cellpadding="0" width="100%" style="width:100%;">
                                  <tr>
                                      <![endif]-->
                                      <!--[if mso]>
                                      <td valign="top" width="600" style="width:600px;">
                                        <![endif]-->
                                        <table align="left" border="0" cellpadding="0" cellspacing="0" style="max-width:100%; min-width:100%;" width="100%" class="mcnTextContentContainer">
                                            <tbody>
                                              <tr>
                                                  <td valign="top" class="mcnTextContent" style="padding-top:0; padding-right:18px; padding-bottom:9px; padding-left:18px;">
                                                    <div style="text-align: center;"><a href="#{
      link_url
    }">#{link_text}</a></div>
                                                  </td>
                                              </tr>
                                            </tbody>
                                        </table>
                                        <!--[if mso]>
                                      </td>
                                      <![endif]-->
                                      <!--[if mso]>
                                  </tr>
                                </table>
                                <![endif]-->
                            </td>
                          </tr>
                      </tbody>
                    </table>
                </td>
              </tr>
          </table>
          <!--[if (gte mso 9)|(IE)]>
        </td>
    </tr>
    </table>
    """
  end

  def code_template(title, subtitle, code) do
    """
    <table align="center" border="0" cellspacing="0" cellpadding="0" width="600" style="width:600px;">
    <tr>
        <td align="center" valign="top" width="600" style="width:600px;">
          <![endif]-->
          <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" class="templateContainer">
              <tr>
                <td valign="top" class="bodyContainer">
                    <table border="0" cellpadding="0" cellspacing="0" width="100%" class="mcnTextBlock" style="min-width:100%;">
                      <tbody class="mcnTextBlockOuter">
                          <tr>
                            <td valign="top" class="mcnTextBlockInner" style="padding-top:9px;">
                                <!--[if mso]>
                                <table align="left" border="0" cellspacing="0" cellpadding="0" width="100%" style="width:100%;">
                                  <tr>
                                      <![endif]-->
                                      <!--[if mso]>
                                      <td valign="top" width="600" style="width:600px;">
                                        <![endif]-->
                                        <table align="left" border="0" cellpadding="0" cellspacing="0" style="max-width:100%; min-width:100%;" width="100%" class="mcnTextContentContainer">
                                            <tbody>
                                              <tr>
                                                  <td valign="top" class="mcnTextContent" style="padding-top:0; padding-right:18px; padding-bottom:9px; padding-left:18px;">
                                                    <h2 style="text-align: center;">#{title}</h2>
                                                    <div style="text-align: center;">#{subtitle}</div>
                                                  </td>
                                              </tr>
                                            </tbody>
                                        </table>
                                        <!--[if mso]>
                                      </td>
                                      <![endif]-->
                                      <!--[if mso]>
                                  </tr>
                                </table>
                                <![endif]-->
                            </td>
                          </tr>
                      </tbody>
                    </table>
                    <table border="0" cellpadding="0" cellspacing="0" width="100%" class="mcnDividerBlock" style="min-width:100%;">
                      <tbody class="mcnDividerBlockOuter">
                          <tr>
                            <td class="mcnDividerBlockInner" style="min-width: 100%; padding: 18px 18px 0px;">
                                <table class="mcnDividerContent" border="0" cellpadding="0" cellspacing="0" width="100%" style="min-width:100%;">
                                  <tbody>
                                      <tr>
                                        <td>
                                            <span></span>
                                        </td>
                                      </tr>
                                  </tbody>
                                </table>
                                <!--            
                                  <td class="mcnDividerBlockInner" style="padding: 18px;">
                                  <hr class="mcnDividerContent" style="border-bottom-color:none; border-left-color:none; border-right-color:none; border-bottom-width:0; border-left-width:0; border-right-width:0; margin-top:0; margin-right:0; margin-bottom:0; margin-left:0;" />
                                  -->
                            </td>
                          </tr>
                      </tbody>
                    </table>
                    <table border="0" cellpadding="0" cellspacing="0" width="100%" class="mcnTextBlock" style="min-width:100%;">
                      <tbody class="mcnTextBlockOuter">
                          <tr>
                            <td valign="top" class="mcnTextBlockInner" style="padding-top:9px;">
                                <!--[if mso]>
                                <table align="left" border="0" cellspacing="0" cellpadding="0" width="100%" style="width:100%;">
                                  <tr>
                                      <![endif]-->
                                      <!--[if mso]>
                                      <td valign="top" width="600" style="width:600px;">
                                        <![endif]-->
                                        <table align="left" border="0" cellpadding="0" cellspacing="0" style="max-width:100%; min-width:100%;" width="100%" class="mcnTextContentContainer">
                                            <tbody>
                                              <tr>
                                                  <td valign="top" class="mcnTextContent" style="padding-top:0; padding-right:18px; padding-bottom:9px; padding-left:18px;">
                                                    <div style="text-align: center;"><h2>#{code}</h2></div>
                                                  </td>
                                              </tr>
                                            </tbody>
                                        </table>
                                        <!--[if mso]>
                                      </td>
                                      <![endif]-->
                                      <!--[if mso]>
                                  </tr>
                                </table>
                                <![endif]-->
                            </td>
                          </tr>
                      </tbody>
                    </table>
                </td>
              </tr>
          </table>
          <!--[if (gte mso 9)|(IE)]>
        </td>
    </tr>
    </table>
    """
  end

  def base_template(content) do
    year = DateTime.utc_now().year

    """
    <!doctype html>
    <html xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office">
    <head>
      <!-- NAME: EDUCATE -->
      <!--[if gte mso 15]>
      <xml>
         <o:OfficeDocumentSettings>
            <o:AllowPNG/>
            <o:PixelsPerInch>96</o:PixelsPerInch>
         </o:OfficeDocumentSettings>
      </xml>
      <![endif]-->
      <meta charset="UTF-8">
      <meta http-equiv="X-UA-Compatible" content="IE=edge">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <title>Welcome to Acme</title>
      <style type="text/css">
         p{
         margin:10px 0;
         padding:0;
         }
         table{
         border-collapse:collapse;
         }
         h1,h2,h3,h4,h5,h6{
         display:block;
         margin:0;
         padding:0;
         }
         img,a img{
         border:0;
         height:auto;
         outline:none;
         text-decoration:none;
         }
         body,#bodyTable,#bodyCell{
         height:100%;
         margin:0;
         padding:0;
         width:100%;
         }
         .mcnPreviewText{
         display:none !important;
         }
         #outlook a{
         padding:0;
         }
         img{
         -ms-interpolation-mode:bicubic;
         }
         table{
         mso-table-lspace:0pt;
         mso-table-rspace:0pt;
         }
         .ReadMsgBody{
         width:100%;
         }
         .ExternalClass{
         width:100%;
         }
         p,a,li,td,blockquote{
         mso-line-height-rule:exactly;
         }
         a[href^=tel],a[href^=sms]{
         color:inherit;
         cursor:default;
         text-decoration:none;
         }
         p,a,li,td,body,table,blockquote{
         -ms-text-size-adjust:100%;
         -webkit-text-size-adjust:100%;
         }
         .ExternalClass,.ExternalClass p,.ExternalClass td,.ExternalClass div,.ExternalClass span,.ExternalClass font{
         line-height:100%;
         }
         a[x-apple-data-detectors]{
         color:inherit !important;
         text-decoration:none !important;
         font-size:inherit !important;
         font-family:inherit !important;
         font-weight:inherit !important;
         line-height:inherit !important;
         }
         .templateContainer{
         max-width:600px !important;
         }
         a.mcnButton{
         display:block;
         }
         .mcnImage,.mcnRetinaImage{
         vertical-align:bottom;
         }
         .mcnTextContent{
         word-break:break-word;
         }
         .mcnTextContent img{
         height:auto !important;
         }
         .mcnDividerBlock{
         table-layout:fixed !important;
         }
         /*
         @tab Page
         @section Heading 1
         @style heading 1
         */
         h1{
         /*@editable*/color:#222222;
         /*@editable*/font-family:Helvetica;
         /*@editable*/font-size:40px;
         /*@editable*/font-style:normal;
         /*@editable*/font-weight:bold;
         /*@editable*/line-height:150%;
         /*@editable*/letter-spacing:normal;
         /*@editable*/text-align:left;
         }
         /*
         @tab Page
         @section Heading 2
         @style heading 2
         */
         h2{
         /*@editable*/color:#444444bf;
         /*@editable*/font-family:Helvetica;
         /*@editable*/font-size:28px;
         /*@editable*/font-style:normal;
         /*@editable*/font-weight:bold;
         /*@editable*/line-height:150%;
         /*@editable*/letter-spacing:normal;
         /*@editable*/text-align:left;
         }
         /*
         @tab Page
         @section Heading 3
         @style heading 3
         */
         h3{
         /*@editable*/color:#444444;
         /*@editable*/font-family:Helvetica;
         /*@editable*/font-size:22px;
         /*@editable*/font-style:normal;
         /*@editable*/font-weight:bold;
         /*@editable*/line-height:150%;
         /*@editable*/letter-spacing:normal;
         /*@editable*/text-align:left;
         }
         /*
         @tab Page
         @section Heading 4
         @style heading 4
         */
         h4{
         /*@editable*/color:#999999;
         /*@editable*/font-family:Georgia;
         /*@editable*/font-size:20px;
         /*@editable*/font-style:italic;
         /*@editable*/font-weight:normal;
         /*@editable*/line-height:125%;
         /*@editable*/letter-spacing:normal;
         /*@editable*/text-align:left;
         }
         /*
         @tab Header
         @section Header Container Style
         */
         #templateHeader{
         /*@editable*/background-color:#FFFFFF;
         /*@editable*/background-image:none;
         /*@editable*/background-repeat:no-repeat;
         /*@editable*/background-position:center;
         /*@editable*/background-size:cover;
         /*@editable*/border-top:0;
         /*@editable*/border-bottom:0;
         /*@editable*/padding-top:54px;
         }
         /*
         @tab Header
         @section Header Interior Style
         */
         .headerContainer{
         /*@editable*/background-color:transparent;
         /*@editable*/background-image:none;
         /*@editable*/background-repeat:no-repeat;
         /*@editable*/background-position:center;
         /*@editable*/background-size:cover;
         /*@editable*/border-top:0;
         /*@editable*/border-bottom:0;
         /*@editable*/padding-top:0;
         /*@editable*/padding-bottom:0;
         }
         /*
         @tab Header
         @section Header Text
         */
         .headerContainer .mcnTextContent,.headerContainer .mcnTextContent p{
         /*@editable*/color:#808080;
         /*@editable*/font-family:Helvetica;
         /*@editable*/font-size:16px;
         /*@editable*/line-height:150%;
         /*@editable*/text-align:left;
         }
         /*
         @tab Header
         @section Header Link
         */
         .headerContainer .mcnTextContent a,.headerContainer .mcnTextContent p a{
         /*@editable*/color:#39aa43;
         /*@editable*/font-weight:normal;
         /*@editable*/text-decoration:underline;
         }
         /*
         @tab Body
         @section Body Container Style
         */
         #templateBody{
         /*@editable*/background-color:#FFFFFF;
         /*@editable*/background-image:none;
         /*@editable*/background-repeat:no-repeat;
         /*@editable*/background-position:center;
         /*@editable*/background-size:cover;
         /*@editable*/border-top:0;
         /*@editable*/border-bottom:0;
         /*@editable*/padding-top:40px;
         /*@editable*/padding-bottom:40px;
         }
         /*
         @tab Body
         @section Body Interior Style
         */
         .bodyContainer{
         /*@editable*/background-color:#c7c7c72e;
         /*@editable*/background-image:none;
         /*@editable*/background-repeat:no-repeat;
         /*@editable*/background-position:center;
         /*@editable*/background-size:cover;
         /*@editable*/border-top:0;
         /*@editable*/border-bottom:0;
         /*@editable*/padding-top:20px;
         /*@editable*/padding-bottom:20px;
         }
         /*
         @tab Body
         @section Body Text
         */
         .bodyContainer .mcnTextContent,.bodyContainer .mcnTextContent p{
         /*@editable*/color:#808080;
         /*@editable*/font-family:Helvetica;
         /*@editable*/font-size:16px;
         /*@editable*/line-height:150%;
         /*@editable*/text-align:left;
         }
         /*
         @tab Body
         @section Body Link
         */
         .bodyContainer .mcnTextContent a,.bodyContainer .mcnTextContent p a{
         /*@editable*/color:#39aa43;
         /*@editable*/font-weight:normal;
         /*@editable*/text-decoration:underline;
         }
         /*
         @tab Footer
         @section Footer Style
         */
         #templateFooter{
         /*@editable*/background-color:#37ab4e;
         /*@editable*/background-image:none;
         /*@editable*/background-repeat:no-repeat;
         /*@editable*/background-position:center;
         /*@editable*/background-size:cover;
         /*@editable*/border-top:0;
         /*@editable*/border-bottom:0;
         /*@editable*/padding-top:15px;
         /*@editable*/padding-bottom:30px;
         }
         /*
         @tab Footer
         @section Footer Interior Style
         */
         .footerContainer{
         /*@editable*/background-color:transparent;
         /*@editable*/background-image:none;
         /*@editable*/background-repeat:no-repeat;
         /*@editable*/background-position:center;
         /*@editable*/background-size:cover;
         /*@editable*/border-top:0;
         /*@editable*/border-bottom:0;
         /*@editable*/padding-top:0;
         /*@editable*/padding-bottom:0;
         }
         /*
         @tab Footer
         @section Footer Text
         */
         .footerContainer .mcnTextContent,.footerContainer .mcnTextContent p{
         /*@editable*/color:#FFFFFF;
         /*@editable*/font-family:Helvetica;
         /*@editable*/font-size:12px;
         /*@editable*/line-height:150%;
         /*@editable*/text-align:center;
         }
         /*
         @tab Footer
         @section Footer Link
         */
         .footerContainer .mcnTextContent a,.footerContainer .mcnTextContent p a{
         /*@editable*/color:#FFFFFF;
         /*@editable*/font-weight:normal;
         /*@editable*/text-decoration:underline;
         }
         @media only screen and (min-width:768px){
         .templateContainer{
         width:600px !important;
         }
         }	@media only screen and (max-width: 480px){
         body,table,td,p,a,li,blockquote{
         -webkit-text-size-adjust:none !important;
         }
         }	@media only screen and (max-width: 480px){
         body{
         width:100% !important;
         min-width:100% !important;
         }
         }	@media only screen and (max-width: 480px){
         .mcnRetinaImage{
         max-width:100% !important;
         }
         }	@media only screen and (max-width: 480px){
         .mcnImage{
         width:100% !important;
         }
         }	@media only screen and (max-width: 480px){
         .mcnCartContainer,.mcnCaptionTopContent,.mcnRecContentContainer,.mcnCaptionBottomContent,.mcnTextContentContainer,.mcnBoxedTextContentContainer,.mcnImageGroupContentContainer,.mcnCaptionLeftTextContentContainer,.mcnCaptionRightTextContentContainer,.mcnCaptionLeftImageContentContainer,.mcnCaptionRightImageContentContainer,.mcnImageCardLeftTextContentContainer,.mcnImageCardRightTextContentContainer,.mcnImageCardLeftImageContentContainer,.mcnImageCardRightImageContentContainer{
         max-width:100% !important;
         width:100% !important;
         }
         }	@media only screen and (max-width: 480px){
         .mcnBoxedTextContentContainer{
         min-width:100% !important;
         }
         }	@media only screen and (max-width: 480px){
         .mcnImageGroupContent{
         padding:9px !important;
         }
         }	@media only screen and (max-width: 480px){
         .mcnCaptionLeftContentOuter .mcnTextContent,.mcnCaptionRightContentOuter .mcnTextContent{
         padding-top:9px !important;
         }
         }	@media only screen and (max-width: 480px){
         .mcnImageCardTopImageContent,.mcnCaptionBottomContent:last-child .mcnCaptionBottomImageContent,.mcnCaptionBlockInner .mcnCaptionTopContent:last-child .mcnTextContent{
         padding-top:18px !important;
         }
         }	@media only screen and (max-width: 480px){
         .mcnImageCardBottomImageContent{
         padding-bottom:9px !important;
         }
         }	@media only screen and (max-width: 480px){
         .mcnImageGroupBlockInner{
         padding-top:0 !important;
         padding-bottom:0 !important;
         }
         }	@media only screen and (max-width: 480px){
         .mcnImageGroupBlockOuter{
         padding-top:9px !important;
         padding-bottom:9px !important;
         }
         }	@media only screen and (max-width: 480px){
         .mcnTextContent,.mcnBoxedTextContentColumn{
         padding-right:18px !important;
         padding-left:18px !important;
         }
         }	@media only screen and (max-width: 480px){
         .mcnImageCardLeftImageContent,.mcnImageCardRightImageContent{
         padding-right:18px !important;
         padding-bottom:0 !important;
         padding-left:18px !important;
         }
         }	@media only screen and (max-width: 480px){
         .mcpreview-image-uploader{
         display:none !important;
         width:100% !important;
         }
         }	@media only screen and (max-width: 480px){
         /*
         @tab Mobile Styles
         @section Heading 1
         @tip Make the first-level headings larger in size for better readability on small screens.
         */
         h1{
         /*@editable*/font-size:30px !important;
         /*@editable*/line-height:125% !important;
         }
         }	@media only screen and (max-width: 480px){
         /*
         @tab Mobile Styles
         @section Heading 2
         @tip Make the second-level headings larger in size for better readability on small screens.
         */
         h2{
         /*@editable*/font-size:26px !important;
         /*@editable*/line-height:125% !important;
         }
         }	@media only screen and (max-width: 480px){
         /*
         @tab Mobile Styles
         @section Heading 3
         @tip Make the third-level headings larger in size for better readability on small screens.
         */
         h3{
         /*@editable*/font-size:20px !important;
         /*@editable*/line-height:150% !important;
         }
         }	@media only screen and (max-width: 480px){
         /*
         @tab Mobile Styles
         @section Heading 4
         @tip Make the fourth-level headings larger in size for better readability on small screens.
         */
         h4{
         /*@editable*/font-size:18px !important;
         /*@editable*/line-height:150% !important;
         }
         }	@media only screen and (max-width: 480px){
         /*
         @tab Mobile Styles
         @section Boxed Text
         @tip Make the boxed text larger in size for better readability on small screens. We recommend a font size of at least 16px.
         */
         .mcnBoxedTextContentContainer .mcnTextContent,.mcnBoxedTextContentContainer .mcnTextContent p{
         /*@editable*/font-size:14px !important;
         /*@editable*/line-height:150% !important;
         }
         }	@media only screen and (max-width: 480px){
         /*
         @tab Mobile Styles
         @section Header Text
         @tip Make the header text larger in size for better readability on small screens.
         */
         .headerContainer .mcnTextContent,.headerContainer .mcnTextContent p{
         /*@editable*/font-size:16px !important;
         /*@editable*/line-height:150% !important;
         }
         }	@media only screen and (max-width: 480px){
         /*
         @tab Mobile Styles
         @section Body Text
         @tip Make the body text larger in size for better readability on small screens. We recommend a font size of at least 16px.
         */
         .bodyContainer .mcnTextContent,.bodyContainer .mcnTextContent p{
         /*@editable*/font-size:16px !important;
         /*@editable*/line-height:150% !important;
         }
         }	@media only screen and (max-width: 480px){
         /*
         @tab Mobile Styles
         @section Footer Text
         @tip Make the footer content text larger in size for better readability on small screens.
         */
         .footerContainer .mcnTextContent,.footerContainer .mcnTextContent p{
         /*@editable*/font-size:14px !important;
         /*@editable*/line-height:150% !important;
         }
         }
      </style>
    </head>
    <body>
      <!--*|IF:MC_PREVIEW_TEXT|*-->
      <!--[if !gte mso 9]><!----><span class="mcnPreviewText" style="display:none; font-size:0px; line-height:0px; max-height:0px; max-width:0px; opacity:0; overflow:hidden; visibility:hidden; mso-hide:all;"></span><!--<![endif]-->
      <!--*|END:IF|*-->
      <center>
         <table align="center" border="0" cellpadding="0" cellspacing="0" height="100%" width="100%" id="bodyTable">
            <tr>
               <td align="center" valign="top" id="bodyCell">
                  <!-- BEGIN TEMPLATE // -->
                  <table border="0" cellpadding="0" cellspacing="0" width="100%">
                     <tr>
                        <td align="center" valign="top" id="templateHeader" data-template-container>
                           <!--[if (gte mso 9)|(IE)]>
                           <table align="center" border="0" cellspacing="0" cellpadding="0" width="600" style="width:600px;">
                              <tr>
                                 <td align="center" valign="top" width="600" style="width:600px;">
                                    <![endif]-->
                                    <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" class="templateContainer">
                                       <tr>
                                          <td valign="top" class="headerContainer">
                                             <table border="0" cellpadding="0" cellspacing="0" width="100%" class="mcnImageBlock" style="min-width:100%;">
                                                <tbody class="mcnImageBlockOuter">
                                                   <tr>
                                                      <td valign="top" style="padding:9px" class="mcnImageBlockInner">
                                                         <table align="left" width="100%" border="0" cellpadding="0" cellspacing="0" class="mcnImageContentContainer" style="min-width:100%;">
                                                            <tbody>
                                                               <tr>
                                                                  <td class="mcnImageContent" valign="top" style="padding-right: 9px; padding-left: 9px; padding-top: 0; padding-bottom: 0; text-align:center;">
                                                                     <a href="http://acme.com" title="Acme " class="" target="_blank">
                                                                     <img align="center" alt="" src="https://gallery.mailchimp.com/q234123412342134.png" width="50" style="max-width:50px; padding-bottom: 0; display: inline !important; vertical-align: bottom;" class="mcnImage">
                                                                     </a>
                                                                  </td>
                                                               </tr>
                                                            </tbody>
                                                         </table>
                                                      </td>
                                                   </tr>
                                                </tbody>
                                             </table>
                                          </td>
                                       </tr>
                                    </table>
                                    <!--[if (gte mso 9)|(IE)]>
                                 </td>
                              </tr>
                           </table>
                           <![endif]-->
                        </td>
                     </tr>
                     <tr>
                        <td align="center" valign="top" id="templateBody" data-template-container>
                           <!--[if (gte mso 9)|(IE)]>
                           #{content}
                           <![endif]-->
                        </td>
                     </tr>
                     <tr>
                        <td align="center" valign="top" id="templateFooter" data-template-container>
                           <!--[if (gte mso 9)|(IE)]>
                           <table align="center" border="0" cellspacing="0" cellpadding="0" width="600" style="width:600px;">
                              <tr>
                                 <td align="center" valign="top" width="600" style="width:600px;">
                                    <![endif]-->
                                    <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" class="templateContainer">
                                       <tr>
                                          <td valign="top" class="footerContainer">
                                             <table border="0" cellpadding="0" cellspacing="0" width="100%" class="mcnFollowBlock" style="min-width:100%;">
                                                <tbody class="mcnFollowBlockOuter">
                                                   <tr>
                                                      <td align="center" valign="top" style="padding:9px" class="mcnFollowBlockInner">
                                                         <table border="0" cellpadding="0" cellspacing="0" width="100%" class="mcnFollowContentContainer" style="min-width:100%;">
                                                            <tbody>
                                                               <tr>
                                                                  <td align="center" style="padding-left:9px;padding-right:9px;">
                                                                     <table border="0" cellpadding="0" cellspacing="0" width="100%" style="min-width: 100%; border: 1px none;" class="mcnFollowContent">
                                                                        <tbody>
                                                                           <tr>
                                                                              <td align="left" valign="middle" style="padding-top:9px; padding-right:9px; padding-left:9px;">
                                                                                 <table class="mcnTextContent" align="left" border="0" cellpadding="0" cellspacing="0">
                                                                                    <tbody>
                                                                                       <tr>
                                                                                          <td align="center" valign="top">
                                                                                             <a href="https://acme.com/privacy.html" target="_blank" style="text-decoration: none;">Privacy Policy</a>
                                                                                             <a href="https://acme.com/terms.html" target="_blank" style="margin: 0 0 0 15px; text-decoration: none;">Terms of Service</a>
                                                                                          </td>
                                                                                       </tr>
                                                                                    </tbody>
                                                                                 </table>
                                                                              </td>
                                                                              <td align="right" valign="top" style="padding-top:9px; padding-right:9px; padding-left:9px;">
                                                                                 <table align="right" border="0" cellpadding="0" cellspacing="0">
                                                                                    <tbody>
                                                                                       <tr>
                                                                                          <td align="center" valign="top">
                                                                                             <!--[if mso]>
                                                                                             <table align="center" border="0" cellspacing="0" cellpadding="0">
                                                                                                <tr>
                                                                                                   <![endif]-->
                                                                                                   <!--[if mso]>
                                                                                                   <td align="center" valign="top">
                                                                                                      <![endif]-->
                                                                                                      <table align="left" border="0" cellpadding="0" cellspacing="0" style="display:inline;">
                                                                                                         <tbody>
                                                                                                            <tr>
                                                                                                               <td valign="top" style="padding-bottom:9px;" class="mcnFollowCoåntentItemContainer">
                                                                                                                  <table border="0" cellpadding="0" cellspacing="0" width="100%" class="mcnFollowContentItem">
                                                                                                                     <tbody>
                                                                                                                        <tr>
                                                                                                                           <td align="left" valign="middle" style="padding-top:5px; padding-bottom:5px;">
                                                                                                                              <table align="left" border="0" cellpadding="0" cellspacing="0" width="">
                                                                                                                                 <tbody>
                                                                                                                                    <tr>
                                                                                                                                       <td align="center" valign="middle" width="30" class="mcnFollowIconContent">
                                                                                                                                          <a href="https://www.instagram.com/acme/" target="_blank"><img src="https://files.constantcontact.com/b733fe89401/9a4a7d41-9ec6-40ee-9107-7b52d8bd03a1.png" style="display:block;" height="30" width="30" class=""></a>
                                                                                                                                       </td>
                                                                                                                                    </tr>
                                                                                                                                 </tbody>
                                                                                                                              </table>
                                                                                                                           </td>
                                                                                                                        </tr>
                                                                                                                     </tbody>
                                                                                                                  </table>
                                                                                                               </td>
                                                                                                            </tr>
                                                                                                         </tbody>
                                                                                                      </table>
                                                                                                      <!--[if mso]>
                                                                                                   </td>
                                                                                                   <![endif]-->
                                                                                                   <!--[if mso]>
                                                                                                   <td align="center" valign="top">
                                                                                                      <![endif]-->
                                                                                                      <table align="left" border="0" cellpadding="0" cellspacing="0" style="display:inline;">
                                                                                                         <tbody>
                                                                                                            <tr>
                                                                                                               <td valign="top" style="padding-bottom:9px;" class="mcnFollowContentItemContainer">
                                                                                                                  <table border="0" cellpadding="0" cellspacing="0" width="100%" class="mcnFollowContentItem">
                                                                                                                     <tbody>
                                                                                                                        <tr>
                                                                                                                           <td align="left" valign="middle" style="padding-top:5px; padding-bottom:5px; padding-left: 10px; padding-right: 10px;">
                                                                                                                              <table align="left" border="0" cellpadding="0" cellspacing="0" width="">
                                                                                                                                 <tbody>
                                                                                                                                    <tr>
                                                                                                                                       <td align="center" valign="middle" width="30" class="mcnFollowIconContent">
                                                                                                                                          <a href="https://twitter.com/acme" target="_blank"><img src="https://files.constantcontact.com/b733fe89401/80e67893-6f58-48a8-b472-53f06c11ca37.png" style="display:block;" height="30" width="30" class=""></a>
                                                                                                                                       </td>
                                                                                                                                    </tr>
                                                                                                                                 </tbody>
                                                                                                                              </table>
                                                                                                                           </td>
                                                                                                                        </tr>
                                                                                                                     </tbody>
                                                                                                                  </table>
                                                                                                               </td>
                                                                                                            </tr>
                                                                                                         </tbody>
                                                                                                      </table>
                                                                                                      <!--[if mso]>
                                                                                                   </td>
                                                                                                   <![endif]-->
                                                                                                   <!--[if mso]>
                                                                                                   <td align="center" valign="top">
                                                                                                      <![endif]-->
                                                                                                      <table align="left" border="0" cellpadding="0" cellspacing="0" style="display:inline;">
                                                                                                         <tbody>
                                                                                                            <tr>
                                                                                                               <td valign="top" style="padding-right:0; padding-bottom:9px;" class="mcnFollowContentItemContainer">
                                                                                                                  <table border="0" cellpadding="0" cellspacing="0" width="100%" class="mcnFollowContentItem">
                                                                                                                     <tbody>
                                                                                                                        <tr>
                                                                                                                           <td align="left" valign="middle" style="padding-top:5px; padding-bottom:5px;">
                                                                                                                              <table align="left" border="0" cellpadding="0" cellspacing="0" width="">
                                                                                                                                 <tbody>
                                                                                                                                    <tr>
                                                                                                                                       <td align="center" valign="middle" width="30" class="mcnFollowIconContent">
                                                                                                                                          <a href="https://www.facebook.com/acme" target="_blank"><img src="https://files.constantcontact.com/b733fe89401/cf4ab55b-4daa-446e-8222-1c78317a7a04.png" style="display:block;" height="30" width="30" class=""></a>
                                                                                                                                       </td>
                                                                                                                                    </tr>
                                                                                                                                 </tbody>
                                                                                                                              </table>
                                                                                                                           </td>
                                                                                                                        </tr>
                                                                                                                     </tbody>
                                                                                                                  </table>
                                                                                                               </td>
                                                                                                            </tr>
                                                                                                         </tbody>
                                                                                                      </table>
                                                                                                      <!--[if mso]>
                                                                                                   </td>
                                                                                                   <![endif]-->
                                                                                                   <!--[if mso]>
                                                                                                </tr>
                                                                                             </table>
                                                                                             <![endif]-->
                                                                                          </td>
                                                                                       </tr>
                                                                                    </tbody>
                                                                                 </table>
                                                                              </td>
                                                                           </tr>
                                                                        </tbody>
                                                                     </table>
                                                                  </td>
                                                               </tr>
                                                            </tbody>
                                                         </table>
                                                      </td>
                                                   </tr>
                                                </tbody>
                                             </table>
                                             <table border="0" cellpadding="0" cellspacing="0" width="100%" class="mcnDividerBlock" style="min-width:100%;">
                                                <tbody class="mcnDividerBlockOuter">
                                                   <tr>
                                                      <td class="mcnDividerBlockInner" style="min-width:100%; padding:18px;">
                                                         <table class="mcnDividerContent" border="0" cellpadding="0" cellspacing="0" width="100%" style="min-width: 100%;border-top: 1px solid #FFFFFF;">
                                                            <tbody>
                                                               <tr>
                                                                  <td>
                                                                     <span></span>
                                                                  </td>
                                                               </tr>
                                                            </tbody>
                                                         </table>
                                                         <!--            
                                                            <td class="mcnDividerBlockInner" style="padding: 18px;">
                                                            <hr class="mcnDividerContent" style="border-bottom-color:none; border-left-color:none; border-right-color:none; border-bottom-width:0; border-left-width:0; border-right-width:0; margin-top:0; margin-right:0; margin-bottom:0; margin-left:0;" />
                                                            -->
                                                      </td>
                                                   </tr>
                                                </tbody>
                                             </table>
                                             <table border="0" cellpadding="0" cellspacing="0" width="100%" class="mcnTextBlock" style="min-width:100%;">
                                                <tbody class="mcnTextBlockOuter">
                                                   <tr>
                                                      <td valign="top" class="mcnTextBlockInner" style="padding-top:9px;">
                                                         <!--[if mso]>
                                                         <table align="left" border="0" cellspacing="0" cellpadding="0" width="100%" style="width:100%;">
                                                            <tr>
                                                               <![endif]-->
                                                               <!--[if mso]>
                                                               <td valign="top" width="600" style="width:600px;">
                                                                  <![endif]-->
                                                                  <table align="left" border="0" cellpadding="0" cellspacing="0" style="max-width:100%; min-width:100%;" width="100%" class="mcnTextContentContainer">
                                                                     <tbody>
                                                                        <tr>
                                                                           <td valign="top" class="mcnTextContent" style="padding-top:0; padding-right:18px; padding-bottom:9px; padding-left:18px;">
                                                                              Copyright ©&nbsp;#{
      year
    } MVC Technologies Inc. All Rights Reserved.<br>
                                                                           </td>
                                                                        </tr>
                                                                     </tbody>
                                                                  </table>
                                                                  <!--[if mso]>
                                                               </td>
                                                               <![endif]-->
                                                               <!--[if mso]>
                                                            </tr>
                                                         </table>
                                                         <![endif]-->
                                                      </td>
                                                   </tr>
                                                </tbody>
                                             </table>
                                          </td>
                                       </tr>
                                    </table>
                                    <!--[if (gte mso 9)|(IE)]>
                                 </td>
                              </tr>
                           </table>
                           <![endif]-->
                        </td>
                     </tr>
                  </table>
                  <!-- // END TEMPLATE -->
               </td>
            </tr>
         </table>
      </center>
    </body>
    </html>
    """
  end

  def welcome_template(url) do
    """
    <html xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office">
      <head>
          <!--[if gte mso 15]>
          <xml>
            <o:OfficeDocumentSettings>
                <o:AllowPNG/>
                <o:PixelsPerInch>96</o:PixelsPerInch>
            </o:OfficeDocumentSettings>
          </xml>
          <![endif]-->
          <meta name="format-detection" content="telephone=no">
          <meta name="viewport" content="width=device-width; initial-scale=1.0; maximum-scale=1.0; user-scalable=no;">
          <meta http-equiv="X-UA-Compatible" content="IE=9; IE=8; IE=7; IE=EDGE" />
          <title>Welcome to Acme</title>
          <link href="https://fonts.googleapis.com/css?family=Open+Sans:400,700" rel="stylesheet">
          <link href="https://fonts.googleapis.com/css?family=Montserrat:400,700" rel="stylesheet">
          <style type="text/css">
            /*@import url(http://fonts.googleapis.com/css?family=Lato:300);*/
            @media screen and (max-width: 600px) {
            .body_content p {
            font-size: 20px !important;
            }
            .mcnTextContent.email_heading p {
            color: #324181;
            letter-spacing: 1.5px;
            text-align: center;
            font-weight: bold;
            margin: 0 auto;
            width: 250px;
            }
            .mcnTextContent.email_subheading p {
            width: 100% !important; 
            }
            .mcnDividerBlock {
            width: 600px !important;
            }
            .templateContainer {
            max-width: 600px !important;
            }
            td.mcnTextContent span {
            font-size: 17px;
            }
            .connect_with_us {
            display: none;
            }
            .social_icons {
            margin: 0 0 0 0 !important;
            }
            table.mcnTextBlock.footer_copyright_block {
            width: 600px;
            }
            .mcnImage {
            max-width: 600px;
            }
            table.mcnTextBlock {
            width: 600px !important;
            margin: 0 auto;
            }
            table.mcnFollowBlock {
            width: 600px !important;
            margin: 0 auto;
            }
            span.article_category p {
            width: 100px !important;
            text-align: center;
            }
            .facebook_icon {
            margin: 0 0 0 220px !important;
            }
            } 		
            .body_content p {
            padding: 0 0 10px 0;
            }
            p{
            margin:10px 0;
            padding:0;
            }
            table{
            border-collapse:collapse;
            }
            h1,h2,h3,h4,h5,h6{
            display:block;
            margin:0;
            padding:0;
            }
            img,a img{
            border:0;
            height:auto;
            outline:none;
            text-decoration:none;
            }
            body,#bodyTable,#bodyCell{
            height:100%;
            margin:0;
            padding:0;
            width:100%;
            font-family: OpenSans;
            }
            .mcnPreviewText{
            display:none !important;
            }
            #outlook a{
            padding:0;
            }
            img{
            -ms-interpolation-mode:bicubic;
            }
            table{
            mso-table-lspace:0pt;
            mso-table-rspace:0pt;
            }
            .ReadMsgBody{
            width:100%;
            }
            .ExternalClass{
            width:100%;
            }
            p,a,li,td,blockquote{
            mso-line-height-rule:exactly;
            }
            a[href^=tel],a[href^=sms]{
            color:inherit;
            cursor:default;
            text-decoration:none;
            }
            p,a,li,td,body,table,blockquote{
            -ms-text-size-adjust:100%;
            -webkit-text-size-adjust:100%;
            }
            .ExternalClass,.ExternalClass p,.ExternalClass td,.ExternalClass div,.ExternalClass span,.ExternalClass font{
            line-height:100%;
            }
            a[x-apple-data-detectors]{
            color:inherit !important;
            text-decoration:none !important;
            font-size:inherit !important;
            font-family:inherit !important;
            font-weight:inherit !important;
            line-height:inherit !important;
            }
            .templateContainer{
            max-width:600px;
            }
            a.mcnButton{
            display:block;
            }
            .mcnImage,.mcnRetinaImage{
            vertical-align:bottom;
            }
            .mcnTextContent{
            word-break:break-word;
            }
            .mcnTextContent img{
            height:auto !important;
            }
            .mcnDividerBlock{
            table-layout:fixed !important;
            }
            .header_graphic_spacer {
            width: 35%;
            }
            .header_graphic_spacer img {
            width: 176px;
            }
            .news_section_heading p {
            text-align: center; 
            letter-spacing: 1.5px; 
            color: #535388; 
            padding: 50px 0 0 0;
            font-size: 20px;
            }
            .news_section_subheading p {
            font-size: 18px;
            color: #535388; 
            }
            a.view_more_btn {
            text-transform: uppercase;
            text-decoration: none;
            letter-spacing: 2.5px;
            font-weight: bold;
            font-size: 13px;
            border-radius: 30px;
            color: #ffffff;
            background-color: #1fc2c0;
            margin: 30px auto;
            padding: 15px 0;
            display: block;
            text-align: center;
            width: 150px;
            }
            /*
            @tab Page
            @section Heading 1
            @style heading 1
            */
            h1{
            /*@editable*/color:#222222;
            /*@editable*/font-family: 'Lato';
            /*@editable*/font-size:40px;
            /*@editable*/font-style:normal;
            /*@editable*/font-weight:bold;
            /*@editable*/line-height:150%;
            /*@editable*/letter-spacing:normal;
            /*@editable*/text-align:center;
            }
            /*
            @tab Page
            @section Heading 2
            @style heading 2
            */
            h2{
            /*@editable*/color:#222222;
            /*@editable*/font-family: 'Lato';
            /*@editable*/font-size:34px;
            /*@editable*/font-style:normal;
            /*@editable*/font-weight:bold;
            /*@editable*/line-height:150%;
            /*@editable*/letter-spacing:normal;
            /*@editable*/text-align:left;
            }
            /*
            @tab Page
            @section Heading 3
            @style heading 3
            */
            h3{
            /*@editable*/color:#444444;
            /*@editable*/font-family: 'Lato';
            /*@editable*/font-size:22px;
            /*@editable*/font-style:normal;
            /*@editable*/font-weight:bold;
            /*@editable*/line-height:150%;
            /*@editable*/letter-spacing:normal;
            /*@editable*/text-align:left;
            }
            /*
            @tab Page
            @section Heading 4
            @style heading 4
            */
            h4{
            /*@editable*/color:#999999;
            /*@editable*/font-family: 'Lato';
            /*@editable*/font-size:20px;
            /*@editable*/font-style:italic;
            /*@editable*/font-weight:normal;
            /*@editable*/line-height:125%;
            /*@editable*/letter-spacing:normal;
            /*@editable*/text-align:left;
            }
            /*
            @tab Header
            @section Header Container Style
            */
            #templateHeader{
            /*@editable*/background-color:#ffffff;
            /*@editable*/background-image:none;
            /*@editable*/background-repeat:no-repeat;
            /*@editable*/background-position:center;
            /*@editable*/background-size:cover;
            /*@editable*/border-top:0;
            /*@editable*/border-bottom:0;
            /*@editable*//*padding-top:15px;*/
            /*@editable*//*padding-bottom:15px;*/
            }
            /*
            @tab Header
            @section Header Interior Style
            */
            .headerContainer{
            /*@editable*/background-color:#transparent;
            /*@editable*/background-image:none;
            /*@editable*/background-repeat:no-repeat;
            /*@editable*/background-position:center;
            /*@editable*/background-size:cover;
            /*@editable*/border-top:0;
            /*@editable*/border-bottom:0;
            /*@editable*/padding-top:0;
            /*@editable*/padding-bottom:0;
            }
            /*
            @tab Header
            @section Header Text
            */
            .headerContainer .mcnTextContent,.headerContainer .mcnTextContent p{
            /*@editable*/color:#808080;
            /*@editable*/font-size:16px;
            /*@editable*/line-height:150%;
            /*@editable*/text-align:left;
            }
            /*
            @tab Header
            @section Header Link
            */
            .headerContainer .mcnTextContent a,.headerContainer .mcnTextContent p a{
            /*@editable*/color:#00ADD8;
            /*@editable*/font-weight:normal;
            /*@editable*/text-decoration:underline;
            }
            /*
            @tab Body
            @section Body Container Style
            */
            .mcnTextContent.email_heading p {
            text-align: center;
            letter-spacing: 1.5px;
            color: #324181;
            font-weight: bold;
            padding: 10px;
            font-size: 25px;
            }
            .mcnTextContent.email_subheading p {
            font-family: 'Montserrat', sans-serif; 
            font-size: 18px;
            color: #535388;
            text-align: center;
            width: 80%;
            margin: 0 auto;
            }
            #templateBody{
            /*@editable*/background-color:#ffffff;
            /*@editable*/background-image:none;
            /*@editable*/background-repeat:no-repeat;
            /*@editable*/background-position:center;
            /*@editable*/background-size:cover;
            /*@editable*/border-top:0;
            /*@editable*/border-bottom:0;
            /*@editable*//*padding-top:36px;*/
            /*@editable*//*padding-bottom:45px;*/
            }
            /*
            @tab Body
            @section Body Interior Style
            */
            .bodyContainer{
            /*@editable*/background-color:#transparent;
            /*@editable*/background-image:none;
            /*@editable*/background-repeat:no-repeat;
            /*@editable*/background-position:center;
            /*@editable*/background-size:cover;
            /*@editable*/border-top:0;
            /*@editable*/border-bottom:0;
            /*@editable*/padding-top:0;
            /*@editable*/padding-bottom:0;
            }
            /*
            @tab Body
            @section Body Text
            */
            td.mcnImageContent img {
            width: 100%;
            }
            table.mcnFollowBlock {
            width: 100%;
            }
            .bodyContainer .mcnTextContent,.bodyContainer .mcnTextContent p{
            /*@editable*/color:#808080;
            /*@editable*/font-family:'Lato', Helvetica, Arial, sans-serif;
            /*@editable*/font-size:20px;
            /*@editable*/line-height:150%;
            /*@editable*/text-align:left;
            }
            /*
            @tab Body
            @section Body Link
            */
            .bodyContainer .mcnTextContent a,.bodyContainer .mcnTextContent p a{
            /*@editable*/color:#00ADD8;
            /*@editable*/font-weight:normal;
            /*@editable*/text-decoration:underline;
            }
            /*
            @tab Footer
            @section Footer Style
            */
            #templateFooter{
            /*@editable*/background-color:#ffffff;
            /*@editable*/background-image:none;
            /*@editable*/background-repeat:no-repeat;
            /*@editable*/background-position:center;
            /*@editable*/background-size:cover;
            /*@editable*/border-top:0;
            /*@editable*/border-bottom:0;
            /*@editable*/padding-top:0px;
            /*@editable*/padding-bottom:0px;
            }
            /*
            @tab Footer
            @section Footer Interior Style
            */
            .footerContainer{
            /*@editable*/background-color:#transparent;
            /*@editable*/background-image:none;
            /*@editable*/background-repeat:no-repeat;
            /*@editable*/background-position:center;
            /*@editable*/background-size:cover;
            /*@editable*/border-top:0;
            /*@editable*/border-bottom:0;
            /*@editable*/padding-top:0;
            /*@editable*/padding-bottom:0;
            }
            /*
            @tab Footer
            @section Footer Text
            */
            .footerContainer .mcnTextContent,.footerContainer .mcnTextContent p{
            /*@editable*/color:#FFFFFF;
            /*@editable*/font-family:'Lato';
            /*@editable*/font-size:12px;
            /*@editable*/line-height:150%;
            /*@editable*/text-align:center;
            }
            /*
            @tab Footer
            @section Footer Link
            */
            .footerContainer .mcnTextContent a,.footerContainer .mcnTextContent p a{
            /*@editable*/color:#FFFFFF;
            /*@editable*/font-weight:normal;
            /*@editable*/text-decoration:underline;
            }
            .mcnDividerBlock.footer_hr {
            width: 600px;
            }
            .social_icons {
            margin: 0 0 0 200px;
            }
            .mcnTextBlock {
            width: 600px;
            }
            @media only screen and (min-width:768px){
            .templateContainer{
            width:600px !important;
            }
            }	@media only screen and (max-width: 600px){
            body,table,td,p,a,li,blockquote{
            -webkit-text-size-adjust:none !important;
            }
            }	@media only screen and (max-width: 600px){
            body{
            width:100% !important;
            min-width:100% !important;
            }
            }	@media only screen and (max-width: 600px){
            .mcnRetinaImage{
            max-width:100% !important;
            }
            }	@media only screen and (max-width: 600px){
            .mcnImage{
            width:100% !important;
            }
            }	@media only screen and (max-width: 600px){
            .mcnCartContainer,.mcnCaptionTopContent,.mcnRecContentContainer,.mcnCaptionBottomContent,.mcnTextContentContainer,.mcnBoxedTextContentContainer,.mcnImageGroupContentContainer,.mcnCaptionLeftTextContentContainer,.mcnCaptionRightTextContentContainer,.mcnCaptionLeftImageContentContainer,.mcnCaptionRightImageContentContainer,.mcnImageCardLeftTextContentContainer,.mcnImageCardRightTextContentContainer,.mcnImageCardLeftImageContentContainer,.mcnImageCardRightImageContentContainer{
            max-width:100% !important;
            width:100% !important;
            }
            }	@media only screen and (max-width: 600px){
            .mcnBoxedTextContentContainer{
            min-width:100% !important;
            }
            }	@media only screen and (max-width: 600px){
            .mcnImageGroupContent{
            padding:9px !important;
            }
            }	@media only screen and (max-width: 600px){
            .mcnCaptionLeftContentOuter .mcnTextContent,.mcnCaptionRightContentOuter .mcnTextContent{
            padding-top:9px !important;
            }
            }	@media only screen and (max-width: 600px){
            .mcnImageCardTopImageContent,.mcnCaptionBottomContent:last-child .mcnCaptionBottomImageContent,.mcnCaptionBlockInner .mcnCaptionTopContent:last-child .mcnTextContent{
            padding-top:18px !important;
            }
            }	@media only screen and (max-width: 600px){
            .mcnImageCardBottomImageContent{
            padding-bottom:9px !important;
            }
            }	@media only screen and (max-width: 600px){
            .mcnImageGroupBlockInner{
            padding-top:0 !important;
            padding-bottom:0 !important;
            }
            }	@media only screen and (max-width: 600px){
            .mcnImageGroupBlockOuter{
            padding-top:9px !important;
            padding-bottom:9px !important;
            }
            }	@media only screen and (max-width: 600px){
            /*.mcnTextContent,.mcnBoxedTextContentColumn{
            padding-right:18px !important;
            padding-left:18px !important;
            }*/
            }	@media only screen and (max-width: 600px){
            .mcnImageCardLeftImageContent,.mcnImageCardRightImageContent{
            padding-right:18px !important;
            padding-bottom:0 !important;
            padding-left:18px !important;
            }
            }	@media only screen and (max-width: 600px){
            .mcpreview-image-uploader{
            display:none !important;
            width:100% !important;
            }
            }	@media only screen and (max-width: 600px){
            /*
            @tab Mobile Styles
            @section Heading 1
            @tip Make the first-level headings larger in size for better readability on small screens.
            */
            h1{
            /*@editable*/font-size:30px !important;
            /*@editable*/line-height:125% !important;
            }
            }	@media only screen and (max-width: 600px){
            /*
            @tab Mobile Styles
            @section Heading 2
            @tip Make the second-level headings larger in size for better readability on small screens.
            */
            h2{
            /*@editable*/font-size:26px !important;
            /*@editable*/line-height:125% !important;
            }
            }	@media only screen and (max-width: 600px){
            /*
            @tab Mobile Styles
            @section Heading 3
            @tip Make the third-level headings larger in size for better readability on small screens.
            */
            h3{
            /*@editable*/font-size:20px !important;
            /*@editable*/line-height:150% !important;
            }
            }	@media only screen and (max-width: 600px){
            /*
            @tab Mobile Styles
            @section Heading 4
            @tip Make the fourth-level headings larger in size for better readability on small screens.
            */
            h4{
            /*@editable*/font-size:18px !important;
            /*@editable*/line-height:150% !important;
            }
            }	@media only screen and (max-width: 600px){
            /*
            @tab Mobile Styles
            @section Boxed Text
            @tip Make the boxed text larger in size for better readability on small screens. We recommend a font size of at least 16px.
            */
            .mcnBoxedTextContentContainer .mcnTextContent,.mcnBoxedTextContentContainer .mcnTextContent p{
            /*@editable*/font-size:14px !important;
            /*@editable*/line-height:150% !important;
            }
            }	@media only screen and (max-width: 600px){
            /*
            @tab Mobile Styles
            @section Header Text
            @tip Make the header text larger in size for better readability on small screens.
            */
            td.mcnImageContent img {
            max-width: 80px !important;
            }
            .headerContainer .mcnTextContent, .headerContainer .mcnTextContent p{
            /*@editable*/font-size:24px !important;
            /*@editable*/line-height:150% !important;
            }
            .footer-social-icons img {
            width: 40px;
            }
            }	@media only screen and (max-width: 600px){
            /*
            @tab Mobile Styles
            @section Body Text
            @tip Make the body text larger in size for better readability on small screens. We recommend a font size of at least 16px.
            */
            .bodyContainer .mcnTextContent,.bodyContainer .mcnTextContent p{
            /*@editable*/font-size:17px !important;
            /*@editable*/line-height:150% !important;
            }
            }	@media only screen and (max-width: 600px){
            /*
            @tab Mobile Styles
            @section Footer Text
            @tip Make the footer content text larger in size for better readability on small screens.
            */
            .footerContainer .mcnTextContent,.footerContainer .mcnTextContent p{
            /*@editable*/font-size:14px !important;
            /*@editable*/line-height:150% !important;
            }
            }
          </style>
      </head>
      <body>
          <!--*|IF:MC_PREVIEW_TEXT|*-->
          <!--[if !gte mso 9]><!----><span class="mcnPreviewText" style="display:none; font-size:0px; line-height:0px; max-height:0px; max-width:0px; opacity:0; overflow:hidden; visibility:hidden; mso-hide:all;"></span><!--<![endif]-->
          <!--*|END:IF|*-->
          <center>
            <table align="center" border="0" cellpadding="0" cellspacing="0" height="100%" width="100%" id="bodyTable">
                <tr>
                  <td align="center" valign="top" id="bodyCell">
                      <!-- BEGIN TEMPLATE // -->
                      <table border="0" cellpadding="0" cellspacing="0" width="100%">
                        <tr>
                            <td align="center" valign="top" id="templateHeader" data-template-container>
                              <!--[if (gte mso 9)|(IE)]>
                              <table align="center" border="0" cellspacing="0" cellpadding="0" width="600" style="width:600px;">
                                  <tr>
                                    <td align="center" valign="top" width="600" style="width:600px;">
                                        <![endif]-->
                                        <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" class="templateContainer" style="background-color: #ffffff;">
                                          <tr>
                                              <td valign="top" class="headerContainer">
                                                <table border="0" cellpadding="0" cellspacing="0" width="100%" class="mcnFollowBlock" style="min-width:100%;">
                                                    <tbody class="mcnFollowBlockOuter">
                                                      <tr>
                                                          <td align="center" valign="top" style="padding:9px" class="mcnFollowBlockInner">
                                                            <table border="0" cellpadding="0" cellspacing="0" width="100%" class="mcnFollowContentContainer" style="min-width:100%;">
                                                                <tbody>
                                                                  <tr>
                                                                      <td align="center" style="padding-left:9px;padding-right:9px;">
                                                                        <table border="0" cellpadding="0" cellspacing="0" width="100%" style="min-width:100%;" class="mcnFollowContent">
                                                                            <tbody>
                                                                              <tr>
                                                                                  <td align="center" valign="top" style="padding-top:9px; padding-right:9px; padding-left:9px;">
                                                                                  </td>
                                                                              </tr>
                                                                            </tbody>
                                                                        </table>
                                                                      </td>
                                                                  </tr>
                                                                </tbody>
                                                            </table>
                                                          </td>
                                                      </tr>
                                                    </tbody>
                                                </table>
                                                <table border="0" cellpadding="0" cellspacing="0" width="100%" class="mcnImageBlock" style="min-width:100%;">
                                                    <tbody class="mcnImageBlockOuter">
                                                      <tr>
                                                          <td valign="top" class="mcnImageBlockInner">
                                                            <table align="left" width="100%" border="0" cellpadding="0" cellspacing="0" class="mcnImageContentContainer" style="min-width:100%;">
                                                                <tbody>
                                                                  <tr>
                                                                      <td class="mcnImageContent" valign="top" style="padding-right: 9px; padding-left: 9px; padding-top: 0; padding-bottom: 0; text-align:center;">
                                                                        <a href="https://acme.com/" target="_blank"><img align="center" alt="" src="https://files.constantcontact.com/b733fe89401/a7f5deb9-d66d-46b2-be10-eae41c4f160f.png" width="84" style="max-width:50px; padding-bottom: 0; display: inline !important; vertical-align: bottom;" class="mcnImage"></a>
                                                                      </td>
                                                                  </tr>
                                                                </tbody>
                                                            </table>
                                                          </td>
                                                      </tr>
                                                    </tbody>
                                                </table>
                                                <table border="0" cellpadding="0" cellspacing="0" width="100%" class="mcnFollowBlock" style="min-width:100%;">
                                                    <tbody class="mcnFollowBlockOuter">
                                                      <tr>
                                                          <td align="center" valign="top" style="padding:9px" class="mcnFollowBlockInner">
                                                            <table border="0" cellpadding="0" cellspacing="0" width="100%" class="mcnFollowContentContainer" style="min-width:100%;">
                                                                <tbody>
                                                                  <tr>
                                                                      <td align="center" style="padding-left:9px;padding-right:9px;">
                                                                        <table border="0" cellpadding="0" cellspacing="0" width="100%" style="min-width:100%;" class="mcnFollowContent">
                                                                            <tbody>
                                                                              <tr>
                                                                                  <td align="center" valign="top" style="padding-top:9px; padding-right:9px; padding-left:9px;">
                                                                                  </td>
                                                                              </tr>
                                                                            </tbody>
                                                                        </table>
                                                                      </td>
                                                                  </tr>
                                                                </tbody>
                                                            </table>
                                                          </td>
                                                      </tr>
                                                    </tbody>
                                                </table>
                                                <table border="0" cellpadding="0" cellspacing="0" width="100%" class="mcnCodeBlock">
                                                    <tbody class="mcnTextBlockOuter">
                                                      <tr>
                                                          <td valign="top" class="mcnTextBlockInner" style="width: 35%;">
                                                            <div class="mcnTextContent header_graphic_spacer">
                                                            </div>
                                                          </td>
                                                          <td valign="top" class="mcnTextBlockInner" style="width: 35%;">
                                                            <div class="mcnTextContent header_graphic_spacer">
                                                            </div>
                                                          </td>
                                                          <!-- <td valign="top" class="mcnTextBlockInner">
                                                            <div class="mcnTextContent header_graphic">
                                                              <img src="http://files.constantcontact.com/b733fe89401/1d754aef-3e9a-4e72-8e0b-dcf93418945d.png" style="width: 176px;">
                                                            </div>
                                                            </td> -->
                                                      </tr>
                                                    </tbody>
                                                </table>
                                                <table border="0" cellpadding="0" cellspacing="0" width="100%" class="mcnCodeBlock">
                                                    <tbody class="mcnTextBlockOuter">
                                                      <tr>
                                                          <td valign="top" class="mcnTextBlockInner">
                                                            <div class="mcnTextContent">
                                                                <img src="https://files.constantcontact.com/b733fe89401/3334254a-04d6-4d2a-b0c5-e7a54371e3ca.png" style="width: 100%;">
                                                            </div>
                                                          </td>
                                                      </tr>
                                                      <tr>
                                                          <td valign="top" class="mcnTextBlockInner">
                                                            <div class="mcnTextContent email_subheading" style="text-align: center; letter-spacing: 1.5px; color: #535388; font-size: 18px; width: 100%; margin: 0 auto;">
                                                                <p style="color: #35ab4c; font-weight: bold; font-family: 'Montserrat', sans-serif; font-size: 25px; padding: 30px 0 10px 0; width: 100%;">WELCOME TO THE ACME FAMILY!</p>
                                                            </div>
                                                          </td>
                                                      </tr>
                                                    </tbody>
                                                </table>
                                                <table border="0" cellpadding="0" cellspacing="0" width="100%" class="mcnCodeBlock">
                                                    <tbody class="mcnTextBlockOuter">
                                                      <tr>
                                                          <td valign="top" class="mcnTextBlockInner">
                                                            <div class="body_content" style="padding: 0 60px;">
                                                                <p style="letter-spacing: normal; color: #454543; padding: 0 0 10px 0; font-size: 18px; line-height: 1.78; font-family: 'Open Sans', sans-serif;">Salutations,</p>
                                                                <p style="letter-spacing: normal; color: #454543; padding: 0 0 10px 0; font-size: 18px; line-height: 1.78; font-family: 'Open Sans', sans-serif;">We are very excited that you have chosen Acme for your loyalty program, and look forward to working with you to make it a great success.</p>
                                                                <p style="letter-spacing: normal; color: #454543; padding: 0 0 10px 0; font-size: 18px; line-height: 1.78; font-family: 'Open Sans', sans-serif;">Your Acme CRM website has been created and is available at the following url: <a href="#{
      url
    }" target="_blank" style="color: #35ab4c; text-decoration: none;">#{url}</a></p>
                                                                <p style="letter-spacing: normal; color: #454543; padding: 0 0 10px 0; font-size: 18px; line-height: 1.78; font-family: 'Open Sans', sans-serif;">You will receive an e-mail shortly with password reset instructions to log in to the CRM.</p>
                                                                <p style="letter-spacing: normal; color: #454543; padding: 0 0 10px 0; font-size: 18px; line-height: 1.78; font-family: 'Open Sans', sans-serif;">Expect to receive your official launch kit and download cards (shipped separately) within 5-7 business days at your business address.</p>
                                                                <p style="letter-spacing: normal; color: #454543; padding: 0 0 10px 0; font-size: 18px; line-height: 1.78; font-family: 'Open Sans', sans-serif;">If you have any questions or problems in regards to setting up Acme, or have not received your launch kit, please don't hesitate to call or email us.</p>
                                                                <p style="letter-spacing: normal; color: #454543; padding: 0 0 10px 0; font-size: 18px; line-height: 1.78; font-family: 'Open Sans', sans-serif;">Thanks,<br>Acme Team<br><a style="color: #35ab4c; text-decoration: none;" href="mailto:info@acme.com">info@acme.com</a></p>
                                                            </div>
                                                          </td>
                                                      </tr>
                                                    </tbody>
                                                </table>
                                                <table border="0" cellpadding="0" cellspacing="0" width="100%" class="footer-social-icons mcnCodeBlock" style="margin: 20px 0 0 0;">
                                                    <tbody class="mcnTextBlockOuter">
                                                      <!-- <tr>
                                                          <td valign="top" class="mcnTextBlockInner">
                                                              <div><p style="text-align: center; color: #535388; font-size: 12px; margin: 0 0 30px 0;">Powered by <a href="" style="text-decoration: underline;"></a></p></div>
                                                          </td>
                                                          </tr> -->
                                                      <tr>
                                                          <td>
                                                            <table align="left" border="0" cellpadding="0" cellspacing="0" style="display:inline; margin: 0 0 0 240px;" class="facebook_icon">
                                                                <tbody>
                                                                  <tr>
                                                                      <td valign="top" style="padding-right:20px; padding-bottom:9px;" class="mcnFollowContentItemContainer">
                                                                        <table border="0" cellpadding="0" cellspacing="0" width="100%" class="mcnFollowContentItem">
                                                                            <tbody>
                                                                              <tr>
                                                                                  <td align="left" valign="middle" style="padding-top:5px; padding-bottom:5px;">
                                                                                    <table align="left" border="0" cellpadding="0" cellspacing="0" width="">
                                                                                        <tbody>
                                                                                          <tr>
                                                                                              <td align="center" valign="middle" width="34" class="mcnFollowIconContent">
                                                                                                <a href="https://www.facebook.com/acme" target="_blank"><img src="https://files.constantcontact.com/b733fe89401/24c6aa32-1b53-4ddc-be02-2c181ff9c675.png" style="display:block;" height="34" width="34" class=""></a>
                                                                                              </td>
                                                                                          </tr>
                                                                                        </tbody>
                                                                                    </table>
                                                                                  </td>
                                                                              </tr>
                                                                            </tbody>
                                                                        </table>
                                                                      </td>
                                                                  </tr>
                                                                </tbody>
                                                            </table>
                                                            <!--[if mso]>
                                                          </td>
                                                          <![endif]-->
                                                          <!--[if mso]>
                                                          <td align="center" valign="top">
                                                            <![endif]-->
                                                            <table align="left" border="0" cellpadding="0" cellspacing="0" style="display:inline;">
                                                                <tbody>
                                                                  <tr>
                                                                      <td valign="top" style="padding-right:20px; padding-bottom:9px;" class="mcnFollowContentItemContainer">
                                                                        <table border="0" cellpadding="0" cellspacing="0" width="100%" class="mcnFollowContentItem">
                                                                            <tbody>
                                                                              <tr>
                                                                                  <td align="left" valign="middle" style="padding-top:5px; padding-bottom:5px;">
                                                                                    <table align="left" border="0" cellpadding="0" cellspacing="0" width="">
                                                                                        <tbody>
                                                                                          <tr>
                                                                                              <td align="center" valign="middle" width="34" class="mcnFollowIconContent">
                                                                                                <a href="https://twitter.com/acme" target="_blank"><img src="https://files.constantcontact.com/b733fe89401/10892caf-78fb-4423-a3c8-b5d00b58573a.png" style="display:block;" height="34" width="34" class=""></a>
                                                                                              </td>
                                                                                          </tr>
                                                                                        </tbody>
                                                                                    </table>
                                                                                  </td>
                                                                              </tr>
                                                                            </tbody>
                                                                        </table>
                                                                      </td>
                                                                  </tr>
                                                                </tbody>
                                                            </table>
                                                            <!--[if mso]>
                                                          </td>
                                                          <![endif]-->
                                                          <!--[if mso]>
                                                          <td align="center" valign="top">
                                                            <![endif]-->
                                                            <table align="left" border="0" cellpadding="0" cellspacing="0" style="display:inline;">
                                                                <tbody>
                                                                  <tr>
                                                                      <td valign="top" style="padding-right:20px; padding-bottom:9px;" class="mcnFollowContentItemContainer">
                                                                        <table border="0" cellpadding="0" cellspacing="0" width="100%" class="mcnFollowContentItem">
                                                                            <tbody>
                                                                              <tr>
                                                                                  <td align="left" valign="middle" style="padding-top:5px; padding-bottom:5px;">
                                                                                    <table align="left" border="0" cellpadding="0" cellspacing="0" width="">
                                                                                        <tbody>
                                                                                          <tr>
                                                                                              <td align="center" valign="middle" width="34" class="mcnFollowIconContent">
                                                                                                <a href="https://www.instagram.com/acme" target="_blank"><img src="https://files.constantcontact.com/b733fe89401/9a4a7d41-9ec6-40ee-9107-7b52d8bd03a1.png" style="display:block;" height="34" width="34" class=""></a>
                                                                                              </td>
                                                                                          </tr>
                                                                                        </tbody>
                                                                                    </table>
                                                                                  </td>
                                                                              </tr>
                                                                            </tbody>
                                                                        </table>
                                                                      </td>
                                                                  </tr>
                                                                </tbody>
                                                            </table>
                                                            <!--[if mso]>
                                                          </td>
                                                          <![endif]-->
                                                          <!--[if mso]>
                                                      </tr>
                                                </table>
                                                <![endif]-->    
                                                <!-- <table align="left" border="0" cellpadding="0" cellspacing="0" style="display:inline;">
                                                    <tbody>
                                                      <tr>
                                                            <td valign="top" style="padding-right:0; padding-bottom:9px;" class="mcnFollowContentItemContainer">
                                                                <table border="0" cellpadding="0" cellspacing="0" width="100%" class="mcnFollowContentItem">
                                                                    <tbody>
                                                                      <tr>
                                                                            <td align="left" valign="middle" style="padding-top:5px; padding-bottom:5px;">
                                                                                <table align="left" border="0" cellpadding="0" cellspacing="0" width="">
                                                                                    <tbody>
                                                                                      <tr>
                                                                                            <td align="center" valign="middle" width="34" class="mcnFollowIconContent">
                                                                                                <a href="https://twitter.com/acme?lang=en" target="_blank"><img src="https://files.constantcontact.com/b733fe89401/6d3c2144-300a-45cc-91ab-0e6bf4c7d056.png" style="display:block;" height="34" width="34" class=""></a>
                                                                                            </td>
                                                                                        </tr>
                                                                                    </tbody>
                                                                                </table>
                                                                            </td>
                                                                        </tr>
                                                                    </tbody>
                                                                </table>
                                                            </td>
                                                        </tr>
                                                    </tbody>
                                                    </table> -->
                                              </td>
                                          </tr>
                                          </tbody>
                                        </table>
                                    </td>
                                  </tr>
                              </table>
                              <!--[if (gte mso 9)|(IE)]>
                            </td>
                        </tr>
                      </table>
                      <![endif]-->
                  </td>
                </tr>
            </table>
          </center>
      </body>
    </html>
    """
  end
end
