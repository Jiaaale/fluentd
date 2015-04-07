#
# Fluentd
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#

require 'fluent/plugin_support/event_loop'

module Fluent
  module PluginSupport
    module Timer
      include Fluent::PluginSupport::EventLoop

      # interval: integer/float, repeat: true/false
      def timer_execute(interval:, repeat: true, &block)
        checker = ->(){ @_timer_running }
        timer = TimerWatcher.new(interval, repeat, log, checker, &block)
        event_loop_attach(timer)
      end

      def initialize
        super
        @_timer_running = true
      end

      def stop
        super
      end

      def shutdown
        @_timer_running = false
        super
      end

      def close
        super
      end

      def terminate
        super
      end

      class TimerWatcher < Coolio::TimerWatcher
        def initialize(interval, repeat, log, checker, &callback)
          @callback = callback
          @log = log
          @checker = checker
          super(interval, repeat)
        end

        def on_timer
          @callback.call if @checker.call()
        rescue => e
          # TODO: raise in tests?
          @log.error "Something wrong in timer callback", error: e, error_class: e.class
          @log.error_backtrace
        end
      end
    end
  end
end
