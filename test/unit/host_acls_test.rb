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
    assert (count_after - count_before) == 1

    assert HostAcl.all.count == 1
    host.destroy
    assert HostAcl.all.count == 0

    count_after_delete = Cmd::count host.id
    assert (count_after_delete - count_after) == 1
  end

  test "delete cascade (deleting host group)" do
    host_group = create :host_group
    host_acl = create :host_acl, :hosts => host_group
    assert HostAcl.all.count == 1
    host_group.destroy
    assert HostAcl.all.count == 0
  end

  test "delete cascade (deleting host group with host)" do
    host_group = create :host_group
    host = create :host
    host_group.host << host
    host_acl = create :host_acl, :hosts => host_group

    count_after = Cmd::count host.id
    assert HostAcl.all.count == 1
    host_group.destroy
    assert HostAcl.all.count == 0
    count_after_delete = Cmd::count host.id
    assert (count_after_delete - count_after) == 1
  end

  test "delete cascade (deleting user)" do
    host_acl = create :host_acl
    count_before = Cmd::count host_acl.hosts.id

    assert HostAcl.all.count == 1
    host_acl.users.destroy
    assert HostAcl.all.count == 0
    count_after = Cmd::count host_acl.hosts.id
    assert (count_after - count_before) == 1
  end

  test "delete cascade (deleting user group)" do
    user_group = create :user_group
    host_acl = create :host_acl, :users => user_group
    count_before = Cmd::count host_acl.hosts.id

    assert HostAcl.all.count == 1
    user_group.destroy
    assert HostAcl.all.count == 0
    count_after = Cmd::count host_acl.hosts.id
    # no command executed, nobody in the group
    assert (count_after - count_before) == 0
  end

  test "delete cascade (deleting user group with someone inside)" do
    user_group = create :user_group
    user_group.user << @admin
    host_acl = create :host_acl, :users => user_group
    count_before = Cmd::count host_acl.hosts.id

    assert HostAcl.all.count == 1
    user_group.destroy
    assert HostAcl.all.count == 0
    count_after = Cmd::count host_acl.hosts.id
    assert (count_after - count_before) == 1
  end
end
