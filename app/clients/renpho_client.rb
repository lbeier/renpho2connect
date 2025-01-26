require 'net/http'
require 'openssl'
require 'base64'

module Clients
    PUBLIC_KEY =
    <<~EOS
    -----BEGIN PUBLIC KEY-----
    MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC+25I2upukpfQ7rIaaTZtVE744
    u2zV+HaagrUhDOTq8fMVf9yFQvEZh2/HKxFudUxP0dXUa8F6X4XmWumHdQnum3zm
    Jr04fz2b2WCcN0ta/rbF2nYAnMVAk2OJVZAMudOiMWhcxV1nNJiKgTNNr13de0EQ
    IiOL2CUBzu+HmIfUbQIDAQAB
    -----END PUBLIC KEY-----
    EOS
    SIGNIN_URL      = "https://renpho.qnclouds.com/api/v3/users/sign_in.json?app_id=Renpho"
    MEASUREMENT_URL = "https://renpho.qnclouds.com/api/v2/measurements/list.json"

    class RenphoClient
        def sign_in(username:, password:)
            uri = URI(SIGNIN_URL)

            data = {
                :email => username,
                :password => encrypt_password(password),
                :secure_flag => 1,
            }

            headers = {
                "content-type": "application/json",
                "accept": "application/json",
                "user-agent": "Renpho/2.1.0 (iPhone; iOS 14.4; Scale/2.1.0; en-US)"
            }

            res = Net::HTTP.post(uri, data.to_json, headers)

            body = JSON.parse(res.body)

            @terminal_user_session_key = body["terminal_user_session_key"]
            @id = body["id"]

            return res
        end

        def get_measurements
            uri = URI(MEASUREMENT_URL)
            _uri = uri.dup
            params = {
                user_id: @id,
                app_id: "Renpho",
                locale: "en",
                terminal_user_session_key: @terminal_user_session_key,
                last_at: "1000000"
            }
            _uri.query = URI.encode_www_form(params)
            res = Net::HTTP.get(_uri)

            return res
        end

        private
        
        def encrypt_password(raw_password)
        public_key = OpenSSL::PKey::RSA.new(PUBLIC_KEY)
        cipher_text = public_key.public_encrypt(raw_password)
        
        Base64.encode64(cipher_text)
        end
    end
end