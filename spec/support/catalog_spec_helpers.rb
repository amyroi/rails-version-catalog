module CatalogSpecHelpers
  def with_raw_features(raw_features, &block)
    with_catalog_singleton_method(FeatureCatalog, :raw_features, raw_features, &block)
  end

  def with_raw_versions(raw_versions, &block)
    with_catalog_singleton_method(VersionCatalog, :raw_versions, raw_versions, &block)
  end

  private
    def with_catalog_singleton_method(klass, method_name, value)
      singleton_class = klass.singleton_class
      original_method = singleton_class.instance_method(method_name)

      singleton_class.send(:define_method, method_name) { value }
      klass.send(:reset_cache!)
      yield
    ensure
      singleton_class.send(:define_method, method_name, original_method)
      klass.send(:reset_cache!)
    end
end
