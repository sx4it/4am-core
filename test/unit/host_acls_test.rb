require 'test_helper'

class HostAclsTest < ActiveSupport::TestCase
  setup do
    create :command, :name => "add_user"
    create :command, :name => "del_user"

    # we set the current_user so that cmd know who launch the command.
    User.current_user = @admin
  end
  test "delete cascade (deleting host)" do
    host = create :host
    count_before = Cmd::count host.id

    host_acl = create :host_acl, :hosts => host
    Cmd::Action.add_host_acl host_acl, @admin

    count_after = Cmd::count host.id
    assert_equal 1, (count_after - count_before)

    assert_equal 1, HostAcl.all.count
    host.destroy
    assert_equal 0, HostAcl.all.count

    count_after_delete = Cmd::count host.id
    assert_equal 1, (count_after_delete - count_after)
  end

  test "delete cascade (deleting host group)" do
    host_group = create :host_group
    host_acl = create :host_acl, :hosts => host_group
    assert_equal 1, HostAcl.all.count
    host_group.destroy
    assert_equal 0, HostAcl.all.count
  end

  test "delete cascade (deleting host group with host)" do
    host_group = create :host_group
    host = create :host
    host_group.host << host
    host_acl = create :host_acl, :hosts => host_group

    count_after = Cmd::count host.id
    assert_equal 1, HostAcl.all.count
    host_group.destroy
    assert_equal 0, HostAcl.all.count
    count_after_delete = Cmd::count host.id
    assert_equal 1, (count_after_delete - count_after)
  end

  test "delete cascade (deleting user)" do
    host_acl = create :host_acl
    count_before = Cmd::count host_acl.hosts.id

    assert_equal 1, HostAcl.all.count
    host_acl.users.destroy
    assert_equal 0, HostAcl.all.count
    count_after = Cmd::count host_acl.hosts.id
    assert_equal 1, (count_after - count_before)
  end

  test "delete cascade (deleting user group)" do
    user_group = create :user_group
    host_acl = create :host_acl, :users => user_group
    count_before = Cmd::count host_acl.hosts.id

    assert_equal 1, HostAcl.all.count
    user_group.destroy
    assert_equal 0, HostAcl.all.count
    count_after = Cmd::count host_acl.hosts.id
    # no command executed, nobody in the group
    assert_equal 0, (count_after - count_before)
  end

  test "delete cascade (deleting user in user group)" do
    user_group = create :user_group
    user = create :user
    user_group.user << user
    host_acl = create :host_acl, :users => user_group
    count_before = Cmd::count host_acl.hosts.id

    assert_equal 1, HostAcl.all.count
    user.destroy
    # deleting user in group should not delete acl
    assert_equal 1, HostAcl.all.count
    count_after = Cmd::count host_acl.hosts.id
    assert_equal 1, (count_after - count_before)
  end

  test "delete cascade (deleting host in host group)" do
    host_group = create :host_group
    host = create :host
    host_group.host << host
    host_acl = create :host_acl, :hosts => host_group
    count_before = Cmd::count host.id

    assert_equal 1, HostAcl.all.count
    host.destroy
    assert_equal 1, HostAcl.all.count
    count_after = Cmd::count host.id
    assert_equal 1, (count_after - count_before)
  end

  test "delete cascade (deleting user group with someone inside)" do
    user_group = create :user_group
    user = create :user
    user_group.user << user
    host_acl = create :host_acl, :users => user_group
    count_before = Cmd::count host_acl.hosts.id

    assert_equal 1, HostAcl.all.count
    user_group.destroy
    assert_equal 0, HostAcl.all.count
    count_after = Cmd::count host_acl.hosts.id
    assert_equal 1, (count_after - count_before)
  end

  test "adding acl (adding user in usergroup with acl)" do
    user_group = create :user_group
    user = create :user
    host_acl = create :host_acl, :users => user_group
    count_before = Cmd::count host_acl.hosts.id

    assert_equal 1, HostAcl.all.count
    user_group.user << user
    assert_equal 1, HostAcl.all.count
    count_after = Cmd::count host_acl.hosts.id
    assert_equal 1, (count_after - count_before)
  end

  test "adding acl (adding host in hostgroup with acl)" do
    host_group = create :host_group
    host = create :host
    host_acl = create :host_acl, :hosts => host_group
    count_before = Cmd::count host.id
    assert_equal 1, HostAcl.all.count
    host_group.host << host
    assert_equal 1, HostAcl.all.count
    count_after = Cmd::count host.id
    assert_equal 1, (count_after - count_before)
  end

#
#  # TODO implement a cleaner way to add key
#
#  test "adding new key (adding new key to user should deploy the key)" do
#    user_group = create :user_group
#    user = create :user
#    user_group.user << user
#    host_acl = create :host_acl, :users => user_group
#    count_before = Cmd::count host_acl.hosts.id
#
#    assert_equal 1, HostAcl.all.count
#    key = create :key
#    user.key << key
#    assert_equal 1, HostAcl.all.count
#    count_after = Cmd::count host_acl.hosts.id
#    assert_equal 1, (count_after - count_before)
#  end
#
#  test "deleting new key (deleting user key should undeploy the key)" do
#    user_group = create :user_group
#    user = create :user
#    user_group.user << user
#    key = create :key
#    user.key << key
#    host_acl = create :host_acl, :users => user_group
#    count_before = Cmd::count host_acl.hosts.id
#
#    assert_equal 1, HostAcl.all.count
#    key.destroy
#    assert_equal 1, HostAcl.all.count
#    count_after = Cmd::count host_acl.hosts.id
#    assert_equal 1, (count_after - count_before)
#  end
#
end
