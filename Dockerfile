FROM pageonex/ruby-base:v1.9.3.2

ENV PATH $PATH:/usr/lib/x86_64-linux-gnu/ImageMagick-6.8.9/bin-Q16/

WORKDIR /tmp
ADD ./Gemfile Gemfile
ADD ./Gemfile.lock Gemfile.lock
RUN bundle install

ENV APP_ROOT /workspace
RUN mkdir -p $APP_ROOT
WORKDIR $APP_ROOT
COPY . $APP_ROOT

EXPOSE  3000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
