require 'singleton'
require 'observer'


class EchoService
  include Observable
  include Singleton


  # Records that the given user has visited the echoable.
  def visited!(echoable, user)
    echo!(echoable, user, :visited => true)
  end

  # Returns true if the given user has visited the echoable.
  #
  # Please rename to 'visited?'
  def visited?(echoable, user)
    echoable.echo ? user.user_echos.visited.for_echo(echoable.echo.id).any? : false
  end

  # Records that the given user has supported the echoable.
  #
  # TODO: Please rename to 'supported!'
  def supported!(echoable, user)
    echo!(echoable, user, :supported => true)
    changed
    notify_observers(:supported, echoable, user)
  end

  # Returns true if the given user supports the echoable.
  #
  # TODO: Please rename to 'supported?'
  def supported?(echoable, user)
    echoable.echo ? user.user_echos.supported.for_echo(echoable.echo.id).any? : false
  end

  #TODO: Please implement the opposite method unsupported!(user) here
  def unsupported!(echoable, user)
    echo!(echoable, user, :supported => false)
    changed
    notify_observers(:unsupported, echoable, user)
  end

  # Returns true if the given user doesn't support the echoable.
  #
  # TODO: Please implement the opposite method unsupported?(user) here
  def unsupported?(echoable, user)
    echoable.echo ? !user.user_echos.supported.for_echo(echoable.echo.id).any? : true
  end

  # Supports the echoable by creating a new user_echo for the given user.
  def echo!(echoable, user, options = {})
    user_echo = echoable.user_echos.create_or_update!(options.merge(:user => user,
                                                                    :echo => echoable.find_or_create_echo))
    # OPTIMIZE: update the counters periodically
    echoable.echo.update_counter!
    user_echo
  end

  def created(node)
    changed
    notify_observers(:created, node)
  end

  def incorporated(echoable, user)
    changed
    notify_observers(:incorporated, echoable, user)
  end
end