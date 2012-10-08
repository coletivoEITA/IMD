# coding: UTF-8

module CaptchaHelper

  def self.open_and_type(img_data)
    captcha_path = '/tmp/captch_path.jpg'
    File.open(captcha_path, 'wb'){ |f| f.write img_data }
    pid = -Process.fork do
      Process.setpgrp
      system "qiv #{captcha_path}"
      #system "jp2a #{captcha_path}"
    end

    print "Type captcha: "
    captcha_code = gets.split("\n").first
    Process.kill 9, pid

    captcha_code
  end

end
