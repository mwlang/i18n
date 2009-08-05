# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')
require 'i18n/backend/active_record'

class I18nActiveRecordBackendTest < Test::Unit::TestCase
  include Tests::Backend::ActiveRecord::Setup::Base
  
  def test_store_translations_does_not_allow_ambigous_keys_1
    I18n::Backend::ActiveRecord::Translation.delete_all
    I18n.backend.store_translations(:en, :foo => 'foo')
    I18n.backend.store_translations(:en, :foo => { :bar => 'bar' })
    I18n.backend.store_translations(:en, :foo => { :baz => 'baz' })
    
    translations = I18n::Backend::ActiveRecord::Translation.locale(:en).lookup('foo', '.').all
    assert_equal %w(bar baz), translations.map(&:value)
    
    assert_equal({ :bar => 'bar', :baz => 'baz' }, I18n.t(:foo))
  end
  
  def test_store_translations_does_not_allow_ambigous_keys_2
    I18n::Backend::ActiveRecord::Translation.delete_all
    I18n.backend.store_translations(:en, :foo => { :bar => 'bar' })
    I18n.backend.store_translations(:en, :foo => { :baz => 'baz' })
    I18n.backend.store_translations(:en, :foo => 'foo')
    
    translations = I18n::Backend::ActiveRecord::Translation.locale(:en).lookup('foo', '.').all
    assert_equal %w(foo), translations.map(&:value)
    
    assert_equal 'foo', I18n.t(:foo)
  end
  
  def test_expand_keys
    assert_equal %w(foo foo.bar foo.bar.baz), I18n.backend.send(:expand_keys, :'foo.bar.baz')
  end
end