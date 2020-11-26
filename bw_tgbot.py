import requests
from bs4 import BeautifulSoup
from telegram.ext import *

token       = ''
bot_usr     = []
bw_endpoint = ''
bw_user     = ''
bw_pass     = ''

def bot_command(update, context):
    if update.message.from_user.id in bot_usr:
        context.bot.send_message(chat_id = update.effective_chat.id,
                                 text = bw_request(update.message.text),
                                 parse_mode = 'HTML')

def bw_request(command):
    global bw_endpoint, bw_user, bw_pass
    headers = {'content-type': 'text/xml'}
    body = """<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:sap-com:document:sap:rfc:functions">
       <soapenv:Header/>
       <soapenv:Body>
          <urn:ZSDI_GETSTATUS_RFC>
             <!--Optional:-->
             <I_COMMAND>""" + command + """</I_COMMAND>
          </urn:ZSDI_GETSTATUS_RFC>
       </soapenv:Body>
    </soapenv:Envelope>"""

    try:
        response = requests.post(bw_endpoint,
                                 data = body,
                                 headers = headers,
                                 auth = (bw_user, bw_pass))
        soup = BeautifulSoup(response.content, 'xml')
        answer = soup.find('E_MESSAGE').contents[0]
    except:
        answer = 'WebService Unavailable'
    return answer

def main():
    updater = Updater(token, use_context = True)
    dp = updater.dispatcher
    dp.add_handler(PrefixHandler('/', 'start', bot_command))
    dp.add_handler(PrefixHandler('/', 'status', bot_command))
    updater.start_polling()
    #updater.idle()

if __name__ == '__main__':
    main()
