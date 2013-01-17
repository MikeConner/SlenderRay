module ApplicationHelper
  MAX_FIRST_NAME_LEN = 24
  MAX_LAST_NAME_LEN = 48
  MAX_ADDRESS_LEN = 50
  MAX_PHONE_LEN = 14
  MAX_ZIPCODE_LEN = 10
  MAX_STATE_LEN = 2
  
  # Plus DC and territories
  US_STATES = %w(AK AL AR AS AZ CA CO CT DC DE FL GA HI IA ID IL IN KS KY LA MA MD ME MI MN MO MP MS 
                 MT NC ND NE NH NJ NM NV NY OH OK OR PA PR RI SC SD TN TX UT VA VI VT WA WI WV WY )
  US_PHONE_REGEX = /^\(\d\d\d\) \d\d\d\-\d\d\d\d$/
  US_ZIP_REGEX = /^\d\d\d\d\d(-\d\d\d\d)?$/
  EMAIL_REGEX = /^\w.*?@\w.*?\.\w+$/
  URL_REGEX = /^((http|https)\:\/\/)?[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(:[a-zA-Z0-9]*)?\/?([a-zA-Z0-9\-\._\?\,\'\/\\\+&amp;%\$#\=~])*[^\.\,\)\(\s]$/
  
  INVALID_EMAILS = ["joe", "joe@", "gmail.com", "@gmail.com", "@Actually_Twitter", "joe.mama@gmail", "fish@.com", "fish@biz.", "test@com"]
  VALID_EMAILS = ["j@z.com", "jeff.bennett@pittsburghmoves.com", "fish_42@verizon.net", "a.b.c.d@e.f.g.h.biz"]
end
